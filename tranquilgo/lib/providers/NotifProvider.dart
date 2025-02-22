import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/api/notif_service.dart';
import 'package:my_app/api/user_service.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsService notifService = NotificationsService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserDetailsService userDetailsService = UserDetailsService();
  List<Map<String, dynamic>> _allNotifications = [];
  bool _isLoading = false;

  bool isNotifsFetched = false;

  List<Map<String, dynamic>> get allNotifications => _allNotifications;
  bool get notifsFetched => isNotifsFetched;
  bool get isLoading => _isLoading;

  void clearUserData() {
    _allNotifications.clear();
    isNotifsFetched = false;
    notifyListeners();
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
      _allNotifications.clear();

      // fetch the first initial notifs before the loop
      List<Map<String, dynamic>> initialNotifs =
          await fetchNotifications(userId, null);

      if (initialNotifs.isNotEmpty) {
        fetchedCount += initialNotifs.length;
        _allNotifications.addAll(initialNotifs);
        totalNotifs = await getUserNotifsCount(userId) ?? 0;
      }

      // continue fetching remaining notifs
      while (fetchedCount < totalNotifs) {
        List<Map<String, dynamic>> fetchedNotifs =
            await fetchNotifications(userId, _allNotifications.last["notifId"]);

        if (fetchedNotifs.isNotEmpty) {
          fetchedCount += fetchedNotifs.length;
          _allNotifications.addAll(fetchedNotifs);
          totalNotifs = await getUserNotifsCount(userId) ?? 0;
        }

        if (fetchedCount >= totalNotifs || fetchedNotifs.isEmpty) {
          break;
        }
      }
    } catch (e) {
      print("Error initializing notifications: $e");
    }

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
}
