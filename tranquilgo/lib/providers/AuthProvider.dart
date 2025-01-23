import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService = AuthService();
  User? _user;

  // getter to check if the user is authenticated
  bool get isAuthenticated => _user != null;

  User? get user => _user;

  Set<String> _usernames = {};
  Set<String> _emails = {};

  Set<String> get usernames => _usernames;
  Set<String> get emails => _emails;

  AuthProvider() {
    _user = authService.getCurrentUser();
  }

  Future<void> fetchExistingUsernamesAndEmails() async {
    try {
      final data = await authService.fetchUsernamesAndEmails();
      _usernames = data['usernames'] ?? {};
      _emails = data['emails'] ?? {};
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load usernames and emails: $e');
    }
  }

  Future<void> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _user = await authService.signUp(
        name: name,
        username: username,
        email: email,
        password: password,
      );
      notifyListeners();
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  // Future<void> login(String username, String password) async {
  //   try {
  //     _user = await authService.login(username, password);
  //     notifyListeners();
  //   } catch (e) {
  //     throw Exception('Login failed: $e');
  //   }
  // }

  Future<String> login(String username, String password) async {
    try {
      final result = await authService.login(username, password);

      // check if login was successful
      if (result == 'success') {
        notifyListeners();
      }

      return result; // pass the error text back to the frontend
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }

  Future<void> logout() async {
    try {
      await authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }
}
