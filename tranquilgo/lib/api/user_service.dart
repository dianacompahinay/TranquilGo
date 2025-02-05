import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:image/image.dart' as img;
import 'package:my_app/api/notif_service.dart';

class UserDetailsService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final NotificationsService notif = NotificationsService();

  // Future<void> createFriendsDocumentsForAllUsers() async {
  //   // Get the list of all users
  //   QuerySnapshot usersSnapshot = await firestore.collection("users").get();

  //   // Loop through all users and create a friends document for each
  //   for (var doc in usersSnapshot.docs) {
  //     String userId = doc.id; // User's UID
  //     String username =
  //         doc["username"]; // Assuming you store usernames in 'username' field

  //     // Create the friends document for this user
  //     await firestore.collection("friends").doc(userId).set({
  //       "username": username,
  //       "friendList": {},
  //     });
  //   }
  // }

  // cloudinary instance
  final cloudinary = Cloudinary.full(
    apiKey: '483599581764523',
    apiSecret: 'vVuK6Dnhi0rr-Qg_wFFjSKcRoAo',
    cloudName: 'de8e3mj0x',
  );

  Future<List<Map<String, dynamic>>> fetchUsers(
      String userId, String? lastUserId) async {
    int limit = 6;

    try {
      Query query = firestore
          .collection("users")
          .orderBy(FieldPath.documentId)
          .limit(limit);

      if (lastUserId != null) {
        DocumentSnapshot lastDoc =
            await firestore.collection('users').doc(lastUserId).get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        } else {
          return [];
        }
      }

      QuerySnapshot usersSnapshot = await query.get();
      if (usersSnapshot.docs.isEmpty) return [];

      List<Map<String, dynamic>> usersList = [];

      // access the friend collection to check the status between the current user and the other user
      DocumentSnapshot friendSnapshot =
          await firestore.collection('friends').doc(userId).get();

      Map<String, dynamic> friendList =
          friendSnapshot.exists ? friendSnapshot['friendList'] ?? {} : {};

      for (var userDoc in usersSnapshot.docs) {
        String friendId = userDoc.id;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String status = friendList.containsKey(friendId)
            ? friendList[friendId]['status']
            : 'add';

        // dont include the current user
        if (friendId != userId) {
          usersList.add({
            "userId": friendId,
            "profileImage": userData.containsKey('profileImage')
                ? userData['profileImage']
                : "no_image",
            "username": userData['username'],
            "name": userData['name'],
            "status": status,
          });
        }
      }
      return usersList;
    } catch (e) {
      throw Exception('Failed to fetch users: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await firestore.collection("friends").doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> connections = userDoc['friendList'];

        List<Map<String, dynamic>> friends = [];

        for (var friendId in connections.keys) {
          // fetch the friend's details from users collection
          DocumentSnapshot friendDoc =
              await firestore.collection("users").doc(friendId).get();

          if (friendDoc.exists) {
            if (connections[friendId]["status"] == "friend") {
              Map<String, dynamic> friendData =
                  friendDoc.data() as Map<String, dynamic>;

              String userImage = friendData.containsKey("profileImage")
                  ? friendDoc["profileImage"]
                  : "no_image";

              friends.add({
                "userId": friendId,
                "profileImage": userImage,
                "username": friendDoc['username'],
                "name": friendDoc['name'],

                // temporary data
                "activeStatus": "offline",
                "steps": 2081,
                "distance": "1.5 km",
                "mood": 5.0,
                "weeklySteps": 10088,
                "weeklyDistance": "7.57 km",
                "weeklyMood": 4.5,
              });
            }
          }
        }

        return friends;
      } else {
        throw Exception("User document not found");
      }
    } catch (e) {
      throw Exception("Error fetching friends: $e");
    }
  }

  Future<void> createFriendsDocument(String userId, String username) async {
    try {
      await firestore
          .collection("friends")
          .doc(userId)
          .set({"username": username, "friendList": {}});
    } catch (e) {
      throw Exception('Failed to create friend user: ${e.toString()}');
    }
  }

  Future<void> sendFriendRequest(String userId, String friendId) async {
    try {
      await firestore.collection("friends").doc(userId).update({
        "friendList.$friendId": {
          "status": "request_sent",
          "dateAdded": FieldValue.serverTimestamp(),
        }
      });

      await firestore.collection("friends").doc(friendId).update({
        "friendList.$userId": {
          "status": "pending_request",
          "dateAdded": FieldValue.serverTimestamp(),
        }
      });

      await notif.createFriendRequestNotif(userId, friendId);
    } catch (e) {
      throw Exception('Failed to send friend request: ${e.toString()}');
    }
  }

  Future<void> acceptFriendRequest(String userId, String friendId) async {
    try {
      await firestore.collection("friends").doc(userId).update({
        "friendList.$friendId": {
          "status": "friend",
          "dateAdded": FieldValue.serverTimestamp(),
        }
      });

      await firestore.collection("friends").doc(friendId).update({
        "friendList.$userId": {
          "status": "friend",
          "dateAdded": FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      throw Exception('Failed to accept friend request: ${e.toString()}');
    }
  }

  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await firestore
          .collection("friends")
          .doc(userId)
          .update({"friendList.$friendId": FieldValue.delete()});

      await firestore
          .collection("friends")
          .doc(friendId)
          .update({"friendList.$userId": FieldValue.delete()});
    } catch (e) {
      throw Exception('Failed to remove friend: ${e.toString()}');
    }
  }

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
