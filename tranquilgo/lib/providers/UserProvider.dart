import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetailsProvider with ChangeNotifier {
  final UserDetailsService _userDetailsService = UserDetailsService();
  final UserDetailsService _authService = UserDetailsService();

  Map<String, dynamic>? _userDetails;
  File? get profileImage => _profileImage;
  Map<String, dynamic>? get userDetails => _userDetails;

  File? _profileImage;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

  Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
    List<Map<String, dynamic>> userList = [];
    _isLoading = true;

    try {
      userList = await _userDetailsService.fetchFriends(userId);
      notifyListeners();
      _isLoading = false;
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
    }

    _isLoading = false;
    return []; // return empty list when there is an error
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
