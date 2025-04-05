import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/api/notif_service.dart';
import 'package:my_app/api/user_service.dart';
import 'package:my_app/local_db.dart';
import 'package:my_app/screens/Social/SocialPage.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsService notifService = NotificationsService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserDetailsService userDetailsService = UserDetailsService();
  List<Map<String, dynamic>> allNotifications = [];
  bool _hasUnreadNotif = false;
  bool _isLoading = false;

  bool isNotifsFetched = false;

  bool get notifsFetched => isNotifsFetched;
  bool get hasUnreadNotif => _hasUnreadNotif;
  bool get isLoading => _isLoading;

  void clearUserData() {
    allNotifications.clear();
    isNotifsFetched = false;
    notifyListeners();
  }

  void listenForNewNotifsMark(
      String userId, GlobalKey<SocialPageState> socialPageKey) {
    bool isFirstSnapshot = true;
    firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .snapshots()
        .listen((snapshot) async {
      if (isFirstSnapshot) {
        isFirstSnapshot = false; // skip the initial snapshot
        return;
      }

      for (var change in snapshot.docChanges) {
        Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;

        // ensure data is valid
        if (data.isEmpty) return;

        if (change.type == DocumentChangeType.added) {
          if (data["type"] == "friend_request_update") {
            socialPageKey.currentState?.refreshConnections();
          }
        }

        hasUnreadNotifOnlineDB(userId);
      }
    });
  }

  void listenForNewNotifications(String userId) {
    bool isFirstSnapshot = true;
    firestore
        .collection("notifications")
        .where("receiverId", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .listen((snapshot) async {
      if (isFirstSnapshot) {
        isFirstSnapshot = false; // skip the initial snapshot
        return;
      }

      for (var change in snapshot.docChanges) {
        Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;

        // ensure data is valid
        if (data.isEmpty) return;

        if (change.type == DocumentChangeType.added) {
          // fetch sender user data
          DocumentSnapshot userDoc =
              await firestore.collection("users").doc(data["senderId"]).get();
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
          String elapsedTime = notifService.getElapsedTime(createdAt);

          // format the notification data
          Map<String, dynamic> newNotification = {};

          if (data["type"] == "system") {
            newNotification = {
              "notifId": change.doc.id,
              "type": data["type"],
              "content": data["content"],
              "time": elapsedTime,
              "isRead": data["isRead"] ?? false,
            };
          } else {
            newNotification = {
              "notifId": change.doc.id,
              "type": data["type"],
              "receiverId": data["receiverId"],
              "senderId": data["senderId"],
              "username": userData["username"],
              "profileImage": userData.containsKey("profileImage")
                  ? userData['profileImage']
                  : "no_image",
              "time": elapsedTime,
              "isRead": data["isRead"] ?? false,
              ...notifService.getNotificationData(data),
            };
          }

          // remove old notification if same senderId, receiverId, and type
          allNotifications.removeWhere((notif) =>
              (notif["senderId"] == newNotification["senderId"] &&
                  notif["receiverId"] == newNotification["receiverId"] &&
                  (notif["type"] == "friend_request" ||
                      notif["type"] == "friend_request_update")));

          // remove notification if same walking invitation
          deleteInvDuplicates(newNotification);

          // insert the new notification at the beginning of the list
          allNotifications.insert(0, newNotification);
          notifyListeners();
        } else if (change.type == DocumentChangeType.modified) {
          if (data["type"] == "friend_request") {
            int existingIndex = allNotifications
                .indexWhere((notif) => notif["notifId"] == change.doc.id);

            // update the status of the friend request notif when accepted from find companions
            allNotifications[existingIndex]["status"] = data["status"];
            notifyListeners();
          }
        }

        // update the indicator if there are unread notifications
        hasUnreadNotifications(userId);
      }
    });
  }

  Future<int?> getUserNotifsCount(String userId) async {
    AggregateQuerySnapshot query = await firestore
        .collection("notifications")
        .where('receiverId', isEqualTo: userId)
        .count()
        .get();
    return query.count;
  }

  Future<List<Map<String, dynamic>>> fetchNotifications(
      String userId, String? lastNotifId) async {
    try {
      List<Map<String, dynamic>> notifications =
          await notifService.getNotifications(userId, lastNotifId);

      notifyListeners();
      return notifications;
    } catch (e) {
      print('Error fetching notifs: $e');
    }

    hasUnreadNotifications(userId);

    return [];
  }

  Future<void> initializeNotifications(String userId) async {
    if (isNotifsFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      isNotifsFetched = true;

      // get total user count
      int totalNotifs = await getUserNotifsCount(userId) ?? 0;
      int fetchedCount = 0;
      allNotifications.clear();

      // fetch the first initial notifs before the loop
      List<Map<String, dynamic>> initialNotifs =
          await fetchNotifications(userId, null);

      if (initialNotifs.isNotEmpty) {
        fetchedCount += initialNotifs.length;
        allNotifications.addAll(initialNotifs);
        totalNotifs = await getUserNotifsCount(userId) ?? 0;
      }

      for (var notif in initialNotifs) {
        await deleteInvDuplicates(notif);
      }

      // continue fetching remaining notifs
      while (fetchedCount < totalNotifs) {
        List<Map<String, dynamic>> fetchedNotifs =
            await fetchNotifications(userId, allNotifications.last["notifId"]);

        if (fetchedNotifs.isNotEmpty) {
          fetchedCount += fetchedNotifs.length;
          allNotifications.addAll(fetchedNotifs);
          totalNotifs = await getUserNotifsCount(userId) ?? 0;
        }

        for (var notif in fetchedNotifs) {
          await deleteInvDuplicates(notif);
        }

        if (fetchedCount >= totalNotifs || fetchedNotifs.isEmpty) {
          break;
        }
      }
    } catch (e) {
      print("Error initializing notifications: $e");
    }

    hasUnreadNotifications(userId);

    _isLoading = false;
    notifyListeners();
  }

  Future<String> acceptFriendRequest(
      String receiverId, String senderId, String notificationId) async {
    try {
      await userDetailsService.acceptFriendRequest(receiverId, senderId);
      notifyListeners();
      await notifService.updateRequestNotif(notificationId, "accepted");
      notifyListeners();
      await notifService.createFriendRequestUpdateNotif(
          receiverId, senderId, "accepted");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while accepting friend request.";
    }
  }

  Future<String> rejectFriendRequest(
      String receiverId, String senderId, String notificationId) async {
    try {
      await userDetailsService.removeFriend(receiverId, senderId);
      notifyListeners();
      await notifService.updateRequestNotif(notificationId, "declined");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while declining friend request.";
    }
  }

  Future<String> acceptInvitationRequest(String receiverId, String senderId,
      Map<String, dynamic> details, String notificationId) async {
    try {
      await notifService.updateRequestNotif(notificationId, "accepted");
      notifyListeners();
      await notifService.createInvitationUpdateNotif(
          receiverId, senderId, details, "accepted");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while accepting invitation.";
    }
  }

  Future<String> rejectInvitationRequest(String receiverId, String senderId,
      Map<String, dynamic> details, String notificationId) async {
    try {
      await notifService.updateRequestNotif(notificationId, "declined");
      notifyListeners();
      await notifService.createInvitationUpdateNotif(
          receiverId, senderId, details, "declined");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while declining invitation.";
    }
  }

  Future<String> sendMessage(
      String senderId, String receiverId, String content) async {
    try {
      await notifService.createMessageNotif(senderId, receiverId, content);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while sending message.";
    }
  }

  Future<String> sendInvitation(
      String senderId, String receiverId, Map<String, dynamic> details) async {
    try {
      await notifService.createInvitationNotif(senderId, receiverId, details);
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while sending invitation.";
    }
  }

  Future<String> deleteNotif(String notificationId) async {
    try {
      await notifService.deleteNotif(notificationId);
      notifyListeners();
      return "success";
    } catch (e) {
      return "Unexpected error occurred while deleting the notification.";
    }
  }

  Future<void> markAsRead(String notifId) async {
    try {
      await notifService.markAsRead(notifId);
      notifyListeners();
    } catch (e) {
      print('Error updating the notif: $e');
    }
  }

  Future<void> markAsUnread(String notifId) async {
    try {
      await notifService.markAsUnread(notifId);
      notifyListeners();
    } catch (e) {
      print('Error updating the notif: $e');
    }
  }

  Future<void> hasUnreadNotifications(String receiverId) async {
    try {
      bool isOnline = await LocalDatabase.isOnline();
      if (!isOnline) {
        _hasUnreadNotif = false;
      } else {
        bool hasUnread =
            allNotifications.any((notif) => notif['isRead'] == false);
        _hasUnreadNotif = hasUnread;
      }
      notifyListeners();
    } catch (e) {
      print('Error checking for unread notifications: $e');
    }
  }

  Future<void> hasUnreadNotifOnlineDB(String receiverId) async {
    try {
      _hasUnreadNotif = await notifService.hasUnreadNotifications(receiverId);

      notifyListeners();
    } catch (e) {
      print('Error checking for unread notifications: $e');
    }
  }

  Future<void> deleteInvDuplicates(Map<String, dynamic> newNotification) async {
    try {
      // find all notifications that match the condition (duplicates)
      List<int> indicesToRemove = [];

      for (int i = 0; i < allNotifications.length; i++) {
        if ((allNotifications[i]["type"] == "walk_invitation" ||
                allNotifications[i]["type"] == "invitation_request_update") &&
            (allNotifications[i]["senderId"] == newNotification["senderId"] &&
                allNotifications[i]["receiverId"] ==
                    newNotification["receiverId"] &&
                allNotifications[i]["details"] == newNotification["details"])) {
          indicesToRemove.add(i);
        }
      }

      // if there are duplicates, remove the extras, but keep the first one
      if (indicesToRemove.isNotEmpty) {
        indicesToRemove.removeAt(0); // keep the first occurrence
        indicesToRemove.forEach((index) async {
          String notifIdToDelete = allNotifications[index]["notifId"];
          allNotifications.removeAt(index);

          // remove the duplicate from the database using its notifId
          await notifService.deleteNotif(notifIdToDelete);
        });

        notifyListeners();
      }
    } catch (e) {
      throw Exception(
          "Unexpected error occurred while deleting the notification.");
    }
  }
}
