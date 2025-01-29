import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDetailsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      return userDoc.data() as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  // re-authenticate the user with their old password before allowing them to set a new one
  // firebase does not allow fetching stored passwords directly
  Future<void> reauthenticateUser(String email, String oldPassword) async {
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: oldPassword);
      await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print('Reauthentication Error: ${e.code}');
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _firebaseAuth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}
