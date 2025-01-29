import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:my_app/api/user_service.dart';

class UserDetailsProvider with ChangeNotifier {
  final UserDetailsService _userDetailsService = UserDetailsService();
  final UserDetailsService _authService = UserDetailsService();

  Map<String, dynamic>? _userDetails;
  Map<String, dynamic>? get userDetails => _userDetails;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
