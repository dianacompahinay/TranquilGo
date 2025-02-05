import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/api/notif_service.dart';
import 'package:my_app/providers/UserProvider.dart';

class NotificationsProvider with ChangeNotifier {
  final NotificationsService notifService = NotificationsService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final UserDetailsProvider userDetailsProvider = UserDetailsProvider();

  get userDetailsService => null;

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

  Future<String> acceptFriendRequest(
      String receiverId, String senderId, String notificationId) async {
    try {
      await userDetailsService.acceptFriendRequest(receiverId, senderId);
      notifyListeners();
      await notifService.updateFriendRequestNotif(notificationId, "accepted");
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
      await notifService.updateFriendRequestNotif(notificationId, "declined");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while declining friend request.";
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
