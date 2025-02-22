import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getNotifications(
      String receiverId, String? lastNotifId) async {
    int limit = 8;

    try {
      Query query = firestore
          .collection('notifications')
          .where('receiverId', isEqualTo: receiverId)
          .orderBy('createdAt', descending: true)
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
      Map<String, List<String>> friendRequestGroups = {};

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
          if (data["type"] == "friend_request" && data["status"] == "pending") {
            String key = "${data["senderId"]}-${data["receiverId"]}";
            // store notifications in a list by sender-receiver pair
            if (!friendRequestGroups.containsKey(key)) {
              friendRequestGroups[key] = [];
            }
            friendRequestGroups[key]!.add(notifDoc.id);
          }

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

      // process friend request notifications
      // additional logic to avoid multiple pending friend request from the same user

      for (var entry in friendRequestGroups.entries) {
        List<String> notifIds = entry.value;

        // the first document in the query result is the latest
        String latestNotif = notifIds.first;

        notifList.removeWhere((notif) =>
            notif["type"] == "friend_request" &&
            notif["notifId"] != latestNotif);

        // delete older friend requests (all except the latest)
        for (int i = 0; i < notifIds.length; i++) {
          if (notifIds[i] != latestNotif) {
            await firestore
                .collection("notifications")
                .doc(notifIds[i])
                .delete();
          }
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
      case "friend_request_update":
        return {"status": data["status"]};
      case "invitation_request_update":
        return {
          "details": data["details"],
          "status": data["status"],
        };
      case "walk_invitation":
        return {
          "details": walkInvitation(data["details"]),
          "status": data["status"]
        };
      case "message":
        return {"content": data["content"] ?? ""};
      default:
        return {};
    }
  }

  Map<String, dynamic> walkInvitation(Map<String, dynamic> details) {
    // format the details to be displayed in frontend
    List<String> dateParts = details['date'].split('-');
    String formattedDateString =
        "${dateParts[0]}-${dateParts[1].padLeft(2, '0')}-${dateParts[2].padLeft(2, '0')}";
    DateTime parsedDate = DateTime.parse(formattedDateString);
    String formattedDate = DateFormat("MMMM d, yyyy").format(parsedDate);
    String weekday = DateFormat("EEEE").format(parsedDate);

    return {
      "date": formattedDate,
      "weekday": weekday,
      "time": details['time'],
      "location": details['location'],
      "message": details['message'],
    };
  }

  Future<void> createFriendRequestNotif(
      String senderId, String receiverId) async {
    try {
      await firestore.collection('notifications').add({
        'type': 'friend_request',
        'senderId': senderId,
        'receiverId': receiverId,
        'status': "pending",
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Failed to create the friend request notification: ${e.toString()}');
    }
  }

  Future<void> createFriendRequestUpdateNotif(
      String senderId, String receiverId, String status) async {
    try {
      // store user details in Firestore
      await firestore.collection('notifications').add({
        'type': 'friend_request_update',
        'senderId': senderId,
        'receiverId': receiverId,
        'status': status,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Failed to create the friend request notification: ${e.toString()}');
    }
  }

  Future<void> createInvitationUpdateNotif(String senderId, String receiverId,
      Map<String, dynamic> details, String status) async {
    try {
      // store user details in Firestore
      await firestore.collection('notifications').add({
        'type': 'invitation_request_update',
        'senderId': senderId,
        'receiverId': receiverId,
        'details': details,
        'status': status,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(
          'Failed to create the friend request notification: ${e.toString()}');
    }
  }

  Future<void> createMessageNotif(
      String senderId, String receiverId, String content) async {
    try {
      await firestore.collection('notifications').add({
        'type': 'message',
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create the message: ${e.toString()}');
    }
  }

  Future<void> createInvitationNotif(
      String senderId, String receiverId, Map<String, dynamic> details) async {
    try {
      await firestore.collection('notifications').add({
        'type': 'walk_invitation',
        'senderId': senderId,
        'receiverId': receiverId,
        'details': details,
        'status': 'pending',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create the message: ${e.toString()}');
    }
  }

  Future<void> updateRequestNotif(String notificationId, String status) async {
    try {
      await firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'status': status});
    } catch (e) {
      throw Exception(
          'Unexpected error occurred while updating request status: ${e.toString()}');
    }
  }

  Future<String> getFriendRequestNotifId(
      String senderId, String receiverId) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('notifications')
          .where('senderId', isEqualTo: senderId)
          .where('receiverId', isEqualTo: receiverId)
          .where('type', isEqualTo: 'friend_request')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      List<QueryDocumentSnapshot> notifDocs = querySnapshot.docs;

      // get the latest notification (most recent)
      String latestNotifId = notifDocs.first.id;

      // delete the duplicates (all except the latest)
      for (int i = 0; i < notifDocs.length; i++) {
        if (notifDocs[i].id != latestNotifId) {
          await firestore
              .collection("notifications")
              .doc(notifDocs[i].id)
              .delete();
        }
      }

      return latestNotifId;
    } catch (e) {
      throw Exception(
          'Failed to fetch and clean friend request notifications: ${e.toString()}');
    }
  }

  Future<void> deleteNotif(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete the notification: ${e.toString()}');
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
