import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getNotifications(
      String receiverId, String? lastNotifId) async {
    int limit = 6;

    try {
      Query query = firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: receiverId)
          // .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastNotifId != null) {
        DocumentSnapshot lastDoc =
            await firestore.collection('notifications').doc(lastNotifId).get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        } else {
          return [];
        }
      }

      QuerySnapshot notifSnapshot = await query.get();
      if (notifSnapshot.docs.isEmpty) return [];

      List<Map<String, dynamic>> notifList = [];

      for (var notifDoc in notifSnapshot.docs) {
        Map<String, dynamic> data = notifDoc.data() as Map<String, dynamic>;

        // calculate time elapsed
        DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        String elapsedTime = getElapsedTime(createdAt);

        DocumentSnapshot userDoc =
            await firestore.collection("users").doc(data["senderId"]).get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (data["type"] == "system") {
          notifList.add({
            "notifId": notifDoc.id,
            "type": data["type"],
            "image": data["image"],
            "content": data["content"],
            "isRead": data["isRead"] ?? false,
          });
        } else {
          notifList.add({
            "notifId": notifDoc.id,
            "type": data["type"],
            "receiverId": receiverId,
            "senderId": data["senderId"],
            "username": userData["username"],
            "profileImage": userData.containsKey("profileImage")
                ? userData['profileImage']
                : "no_image",
            "time": elapsedTime,
            "isRead": data["isRead"] ?? false,
            ...getNotificationData(data),
          });
        }
      }
      return notifList;
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  String getElapsedTime(DateTime createdAt) {
    Duration difference = DateTime.now().difference(createdAt);

    if (difference.inMinutes < 1) return "Just now";
    if (difference.inMinutes < 60) return "${difference.inMinutes}m";
    if (difference.inHours < 24) return "${difference.inHours}h";
    if (difference.inDays < 7) return "${difference.inDays}d";
    return "${(difference.inDays / 7).floor()}w";
  }

  Map<String, dynamic> getNotificationData(Map<String, dynamic> data) {
    switch (data["type"]) {
      case "friend_request":
        return {"status": data["status"]};
      case "walk_invitation":
        return {"details": data["details"], "status": data["status"]};
      case "message":
        return {"content": data["content"] ?? ""};
      default:
        return {};
    }
  }

  Future<void> createFriendRequestNotif(
      String senderId, String receiverId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(senderId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      // store user details in Firestore
      await firestore.collection('notifications').add({
        'type': 'friend_request',
        'senderId': senderId,
        'receiverId': receiverId,
        'username': userData["username"],
        'profileImage': userData.containsKey("profileImage")
            ? userData['profileImage']
            : "no_image",
        'status': "pending",
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Failed to create the friend request notification: ${e.toString()}');
    }
  }

  Future<void> updateFriendRequestNotif(
      String notificationId, String status) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'status': status});
    } catch (e) {
      throw Exception(
          'Unexpected error occurred while updating friend request status: ${e.toString()}');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to update notifications: ${e.toString()}');
    }
  }

  Future<void> markAsUnread(String notificationId) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': false});
    } catch (e) {
      throw Exception('Failed to update notifications: ${e.toString()}');
    }
  }
}
