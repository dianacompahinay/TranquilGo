import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/api/user_service.dart';
// import 'package:my_app/api/activity_service.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<Map<String, Set<String>>> fetchUsernamesAndEmails() async {
    try {
      // fetch all usernames and their associated emails
      final usernameSnapshot = await firestore.collection('usernames').get();

      // extract usernames and emails
      final usernames = usernameSnapshot.docs.map((doc) => doc.id).toSet();
      final emails =
          usernameSnapshot.docs.map((doc) => doc['email'] as String).toSet();

      return {'usernames': usernames, 'emails': emails};
    } catch (e) {
      throw Exception('Failed to fetch usernames and emails: $e');
    }
  }

  // for new user
  Future<User?> signUp({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // create user in Firebase Auth
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // get the created user's UID
      final String userId = userCredential.user?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception("Failed to create user: User ID is null.");
      }

      // store user details in Firestore
      await firestore.collection('users').doc(userId).set({
        'name': name,
        'username': username,
        'email': email,
        'steps': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // map username to email for login
      await firestore.collection('usernames').doc(username).set({
        'email': email,
      });

      UserDetailsService users = UserDetailsService();
      users.createFriendsDocument(userId, username);

      // ActivityService weeklyActivity = ActivityService();
      // weeklyActivity.createWeeklyActivityForNewUser(userId);

      return userCredential.user;
    } catch (e) {
      throw Exception('Sign-up failed: ${e.toString()}');
    }
  }

  Future<String> login(String username, String password) async {
    try {
      // check if the username exists in Firestore
      final usernameSnapshot =
          await firestore.collection('usernames').doc(username).get();

      if (!usernameSnapshot.exists) {
        return 'The username does not exist.';
      }

      final email = usernameSnapshot['email'];

      // attempt to sign in using email and password
      await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      // login successful
      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'The password you entered is incorrect.';
      } else if (e.code == 'user-not-found') {
        return 'The username or email does not exist.';
      } else if (e.code == 'invalid-credential') {
        return 'The provided credentials are invalid.';
      } else {
        return 'An error occurred during login. Please try again later.';
      }
    } catch (e) {
      // catch any other errors
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }
}
