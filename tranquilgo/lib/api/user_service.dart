import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:image/image.dart' as img;

class UserDetailsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // cloudinary instance
  final cloudinary = Cloudinary.full(
    apiKey: '483599581764523',
    apiSecret: 'vVuK6Dnhi0rr-Qg_wFFjSKcRoAo',
    cloudName: 'de8e3mj0x',
  );

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      // check if file exists
      if (!imageFile.existsSync()) {
        return null;
      }

      final compressedFile = await compressImage(File(imageFile.path));

      // upload image to cloudinary
      final response = await cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: compressedFile.path,
          resourceType: CloudinaryResourceType.image,
          folder: 'profile_images',
          publicId: "$userId${DateTime.now().millisecondsSinceEpoch}",
          progressCallback: (count, total) {
            print('Uploading: $count/$total');
          },
        ),
      );

      if (response.isSuccessful) {
        // save url in database
        await firestore
            .collection('users')
            .doc(userId)
            .update({'profileImage': response.secureUrl});

        return response.secureUrl;
      } else {
        // error uploading image
        return null;
      }
    } catch (e) {
      // error uploading image
      return null;
    }
  }

  Future<File> compressImage(File imageFile) async {
    final rawImage = img.decodeImage(await imageFile.readAsBytes());
    final compressed = img.encodeJpg(rawImage!, quality: 80); // adjust quality
    final newFile = File(imageFile.path)..writeAsBytesSync(compressed);
    return newFile;
  }

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

  Future<bool> isUsernameTaken(String username) async {
    final query = await firestore.collection('usernames').doc(username).get();
    return query.exists;
  }

  Future<void> updateUserDetails(String userId,
      {String? name, String? username, String? email}) async {
    try {
      Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;

      if (username != null) {
        // check if username is already taken
        if (await isUsernameTaken(username)) {
          throw Exception('username_taken');
        }

        updates['username'] = username;

        // remove old username from 'usernames' collection
        final userDoc = await firestore.collection('users').doc(userId).get();
        String? oldUsername = userDoc.data()?['username'];
        if (oldUsername != null) {
          await firestore.collection('usernames').doc(oldUsername).delete();
        }

        // add new username to 'usernames' collection
        await firestore
            .collection('usernames')
            .doc(username)
            .set({'email': email});
      }

      // update user document
      if (updates.isNotEmpty) {
        await firestore.collection('users').doc(userId).update(updates);
      }
    } catch (e) {
      print("Error updating user details: $e");
      throw Exception("Failed to update user details");
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
