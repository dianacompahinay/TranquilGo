import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/user_service.dart';
import 'package:my_app/api/notif_service.dart';

class UserDetailsProvider with ChangeNotifier {
  final UserDetailsService _userDetailsService = UserDetailsService();
  final UserDetailsService _authService = UserDetailsService();
  final NotificationsService _notifService = NotificationsService();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _userDetails;
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _searchedUsers = [];
  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _topUsers = [];
  File? _profileImage;
  String? _errorMessage;
  String? searchQuery;
  bool _isLoading = false;
  bool _searchLoading = false;

  bool isFriendsFetched = false;
  bool isTopUsersFetched = false;
  bool isSearchedUsersFetched = false;

  Map<String, dynamic>? get userDetails => _userDetails;
  List<Map<String, dynamic>> get allUsers => _allUsers;
  List<Map<String, dynamic>> get searchedUsers => _searchedUsers;
  List<Map<String, dynamic>> get friends => _friends;
  List<Map<String, dynamic>> get topUsers => _topUsers;
  File? get profileImage => _profileImage;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get searchLoading => _searchLoading;

  bool get friendsFetched => isFriendsFetched;
  bool get topUsersFetched => isTopUsersFetched;
  bool get searchedUsersFetched => isSearchedUsersFetched;

  void clearUserData() {
    _allUsers.clear();
    _searchedUsers.clear();
    _friends.clear();
    _topUsers.clear();
    searchQuery = null;
    isFriendsFetched = false;
    isTopUsersFetched = false;
    isSearchedUsersFetched = false;
    notifyListeners();
  }

  void setFetchToFalse() {
    isFriendsFetched = false;
    isTopUsersFetched = false;
  }

  Future<int?> getUsersCount() async {
    AggregateQuerySnapshot query =
        await firestore.collection("users").count().get();
    return query.count;
  }

  Future<List<Map<String, dynamic>>> fetchUsers(
      String userId, String? lastUserId) async {
    try {
      List<Map<String, dynamic>> users =
          await _userDetailsService.fetchUsers(userId, lastUserId);
      notifyListeners();
      return users;
    } catch (e) {
      print('Error fetching users: $e');
    }

    return [];
  }

  Future<void> initializeUsers(String userId) async {
    if (isSearchedUsersFetched) return;

    _searchLoading = true;
    notifyListeners();

    try {
      isSearchedUsersFetched = true;

      // get total user count
      int totalUsers = await getUsersCount() ?? 0;
      int fetchedCount = 0;
      _allUsers.clear();
      _searchedUsers.clear();

      // fetch the first users before the loop
      List<Map<String, dynamic>> initialUsers = await fetchUsers(userId, null);
      if (initialUsers.isNotEmpty) {
        fetchedCount += initialUsers.length;
        _allUsers.addAll(initialUsers);
      }

      while (fetchedCount < totalUsers - 1) {
        List<Map<String, dynamic>> fetchedUsers =
            await fetchUsers(userId, _allUsers.last["userId"]);

        if (fetchedUsers.isNotEmpty) {
          fetchedCount += fetchedUsers.length;
          _allUsers.addAll(fetchedUsers);
        }

        if (fetchedCount >= totalUsers - 1) {
          break;
        }
      }

      if (searchQuery != null && searchQuery != '') {
        searchUsers(searchQuery!);
      }
    } catch (e) {
      print("Error initializing users: $e");
    }

    _searchLoading = false;
    notifyListeners();
  }

  void searchUsers(String query) {
    _searchedUsers = _allUsers
        .where((user) =>
            user["username"].toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
  }

  Future<void> fetchFriends(String userId) async {
    if (isFriendsFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      _friends = await _userDetailsService.fetchFriends(userId);
      notifyListeners();
      isFriendsFetched = true;
    } catch (e) {
      print('Error fetching users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTopUsers(String userId) async {
    if (isTopUsersFetched) return;

    _isLoading = true;
    notifyListeners();

    try {
      _topUsers = await _userDetailsService.fetchTopUsers(userId);
      notifyListeners();
      isTopUsersFetched = true;
    } catch (e) {
      print('Error fetching top users: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> sendFriendRequest(String userId, String friendId) async {
    try {
      await _userDetailsService.sendFriendRequest(userId, friendId);
      notifyListeners();
      return "success";
    } catch (e) {
      return "Unexpected error occurred while sending friend request.";
    }
  }

  Future<String> acceptFriendRequest(String userId, String friendId) async {
    try {
      await _userDetailsService.acceptFriendRequest(userId, friendId);
      notifyListeners();

      // create and update notifications
      await _notifService.createFriendRequestUpdateNotif(
          userId, friendId, "accepted");
      notifyListeners();

      String notificationId =
          await _notifService.getFriendRequestNotifId(friendId, userId);
      await _notifService.updateRequestNotif(notificationId, "accepted");
      notifyListeners();

      return "success";
    } catch (e) {
      return "Unexpected error occurred while accepting friend request.";
    }
  }

  Future<String> rejectFriendRequest(String userId, String friendId) async {
    try {
      await _userDetailsService.removeFriend(userId, friendId);
      notifyListeners();
      return "success";
    } catch (e) {
      return "Unexpected error occurred while rejecting friend request.";
    }
  }

  Future<String> cancelFriendRequest(String userId, String friendId) async {
    try {
      await _userDetailsService.removeFriend(userId, friendId);
      notifyListeners();

      // delete notif when friend request is cancelled
      String notificationId =
          await _notifService.getFriendRequestNotifId(userId, friendId);
      await _notifService.deleteNotif(notificationId);

      notifyListeners();
      return "success";
    } catch (e) {
      return "Unexpected error occurred while cancelling the friend request.";
    }
  }

  Future<String> removeFriend(String userId, String friendId) async {
    try {
      await _userDetailsService.removeFriend(userId, friendId);
      notifyListeners();
      return "success";
    } catch (e) {
      return "Unexpected error occurred while removing the friend.";
    }
  }

  Future<String?> uploadUserImage(String userId, File image) async {
    try {
      _profileImage = image;
      notifyListeners();

      String? imageUrl =
          await _userDetailsService.uploadProfileImage(userId, image);

      if (imageUrl != null) {
        _userDetails?['profileImage'] = imageUrl;
        notifyListeners();
        return imageUrl;
      }

      return "error";
    } catch (e) {
      print("Error uploading user image: $e");
      return "error";
    }
  }

  Future<void> fetchUserDetails(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userDetails = await _userDetailsService.getUserDetails(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> changeUserDetails(String userId, String? newName,
      String? newUsername, String currentEmail) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // check if username is being changed and if it is already taken
      if (newUsername != null && newUsername != _userDetails?['username']) {
        if (await _userDetailsService.isUsernameTaken(newUsername)) {
          return 'username_taken';
        }
      }

      // update
      await _userDetailsService.updateUserDetails(userId,
          name: newName, username: newUsername, email: currentEmail);
      if (newName != null) _userDetails?['name'] = newName;
      if (newUsername != null) _userDetails?['username'] = newUsername;

      notifyListeners();
      return 'success';
    } catch (e) {
      _errorMessage = e.toString();
      return 'error';
    }
  }

  Future<String> updatePassword(
      String email, String oldPassword, String newPassword) async {
    _errorMessage = null;
    notifyListeners();

    try {
      // verify the old password
      await _authService.reauthenticateUser(email, oldPassword);

      // attempt to change the password
      await _authService.changePassword(newPassword);
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 'incorrect_old_password'; // old password is incorrect
      } else {
        return 'update_failed'; // failed to update the new password
      }
    } catch (e) {
      _errorMessage = e.toString();
      return 'unknown_error';
    } finally {
      notifyListeners();
    }
  }

  void clearUserDetails() {
    _userDetails = null;
    _errorMessage = null;
    notifyListeners();
  }
}
