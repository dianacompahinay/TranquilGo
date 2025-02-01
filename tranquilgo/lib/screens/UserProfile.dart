// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/AuthProvider.dart';
import 'package:my_app/components/ChangePassword.dart';
import 'package:my_app/providers/UserProvider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  File? profileImage;

  late TextEditingController nameController = TextEditingController();
  late TextEditingController usernameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();

  // for error messages
  String? nameError;
  String? usernameError;
  String? emailError;

  String initialName = "";
  String initialUsername = "";

  bool isEditable = false;
  bool isButtonClicked = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    // ensures that the fetch happens after the current build phase (delay triggering the fetch)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Provider.of<UserDetailsProvider>(context, listen: false)
            .fetchUserDetails(userId)
            .then((_) {
          final userProfileProvider =
              Provider.of<UserDetailsProvider>(context, listen: false);
          final userDetails = userProfileProvider.userDetails;

          if (userDetails != null) {
            nameController.text = userDetails["name"] ?? "";
            usernameController.text = userDetails["username"] ?? "";
            emailController.text = userDetails["email"] ?? "";

            setState(() {
              initialName = userDetails["name"] ?? "";
              initialUsername = userDetails["username"] ?? "";
            });
          }
        }).catchError((error) {
          print('$error');
        });
      }
    });
  }

  @override
  void dispose() {
    // dispose text controllers when widget is removed
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileProvider = Provider.of<UserDetailsProvider>(context);
    final isLoading = userProfileProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 50,
        leading: Container(
          margin: const EdgeInsets.only(left: 10),
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/images/back-arrow.png',
                fit: BoxFit.contain,
                color: const Color(0xFF6C6C6C),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Text(
          "User Profile",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF110000),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 46, right: 46, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // profile icon
                  Center(
                    child: Stack(
                      children: [
                        // main profile container
                        isLoading
                            ? loadingUserImage()
                            : Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFACACAC),
                                    width: 1,
                                  ),
                                ),
                                child: Consumer<UserDetailsProvider>(
                                  builder:
                                      (context, userDetailsProvider, child) {
                                    String? imageUrl = userDetailsProvider
                                        .userDetails?['profileImage'];

                                    return CircleAvatar(
                                      radius: 65,
                                      backgroundColor: Colors.white,
                                      backgroundImage: profileImage != null
                                          ? FileImage(
                                              profileImage!) // show local file if newly uploaded
                                          : imageUrl != null &&
                                                  imageUrl.isNotEmpty
                                              ? NetworkImage(imageUrl)
                                                  as ImageProvider
                                              : null,
                                      child: (profileImage == null &&
                                              (imageUrl == null ||
                                                  imageUrl.isEmpty))
                                          ? const Icon(
                                              Icons.person,
                                              size: 95,
                                              color: Color(0xFF73C2C4),
                                            )
                                          : null,
                                    );
                                  },
                                ),
                              ),
                        // photo upload
                        isEditable
                            ? Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: pickImage,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF87D3D8),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // name field
                  isLoading
                      ? loadingTextField()
                      : buildField(
                          "Name",
                          "Enter name",
                          nameError,
                          nameController,
                          validateName,
                        ),

                  // username field
                  isLoading
                      ? loadingTextField()
                      : buildField(
                          "Username",
                          "Enter username",
                          usernameError,
                          usernameController,
                          validateUsername,
                        ),

                  // email field
                  isLoading
                      ? loadingTextField()
                      : buildField(
                          "Email",
                          "Enter email",
                          emailError,
                          emailController,
                          validateEmail,
                        ),

                  const SizedBox(height: 30),

                  // change password
                  isEditable
                      ? ChangePassword(email: emailController.text)
                      : const SizedBox(height: 20),

                  const SizedBox(height: 10),

                  // edit profile button
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[200]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: isUpdating
                              ? null
                              : () {
                                  handleSave();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF55AC9F),
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: isUpdating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 4,
                                  ),
                                )
                              : DefaultTextStyle(
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: Text(isEditable
                                      ? 'Save Changes'
                                      : 'Edit Profile'),
                                ),
                        ),

                  const SizedBox(height: 16),

                  // log out button
                  isLoading
                      ? const SizedBox()
                      : Center(
                          child: InkWell(
                            onTap: () => logOut(),
                            child: DefaultTextStyle(
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  color: Color(0xFF494949),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text('Log out'),
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  // reusable function to build text fields
  Widget buildField(
    String label,
    String hint,
    String? errorText,
    TextEditingController controller,
    Function(String) validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          ),
          TextField(
            controller: controller,
            onChanged: (value) {
              // remove error text when the user types
              validator(value);
            },
            enabled: label == "Email" ? false : isEditable,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isEditable && label != "Email"
                    ? const Color(0xFF000000)
                    : const Color(0xFF616161),
              ),
            ),
            decoration: InputDecoration(
              hintText: hint,
              errorText: isButtonClicked ? errorText : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 18.0,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF919191),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFF55AC9F),
                  width: 2.0,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(
                  color: Color(0xFFDBDBDB),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFC14040),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Color(0xFFC14040),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleSave() async {
    validateName(nameController.text);
    validateUsername(usernameController.text);
    // check validation for all fields
    bool isValid =
        nameError == null && usernameError == null && emailError == null;

    if (isEditable) {
      setState(() {
        isButtonClicked = true;
      });
      if (isValid) {
        // wait for result after clicking the button and the input fields are valid
        setState(() {
          isUpdating = true;
        });

        String? userId = FirebaseAuth.instance.currentUser?.uid;

        // uploading user's profile image
        if (userId != null && profileImage != null) {
          String? uploadResult =
              await Provider.of<UserDetailsProvider>(context, listen: false)
                  .uploadUserImage(userId, profileImage!);

          if (uploadResult == "error") {
            showBottomSnackBar(context, "Failed to upload the image.");
            setState(() {
              profileImage = null;
            });
          }
        }

        // updating the user's detail
        String? newName = nameController.text.trim() != initialName
            ? nameController.text.trim()
            : null;
        String? newUsername = usernameController.text.trim() != initialUsername
            ? usernameController.text.trim()
            : null;

        if (userId != null) {
          String result =
              await Provider.of<UserDetailsProvider>(context, listen: false)
                  .changeUserDetails(
                      userId, newName, newUsername, emailController.text);

          if (result == 'username_taken') {
            setState(() {
              usernameError = 'Username is already taken';
              isUpdating = false;
            });
          } else if (result == 'success') {
            setState(() {
              // save changes when edit is success
              initialName = nameController.text;
              initialUsername = usernameController.text;
              isEditable = false;
              isButtonClicked = false;
              isUpdating = false;
            });
          } else {
            showBottomSnackBar(
                context, "Failed to save changes. Please try again later.");
            setState(() {
              // dont save changes when edit fails
              nameController.text = initialName;
              usernameController.text = initialUsername;
              isEditable = false;
              isButtonClicked = false;
              isUpdating = false;
            });
          }
        }
      }
    } else {
      setState(() {
        isEditable = true; // enable editing
      });
    }
  }

  void validateName(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        nameError = 'Name is required';
      } else {
        nameError = null;
      }
    });
  }

  void validateUsername(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        usernameError = 'Username is required';
      } else if (value.contains(' ')) {
        usernameError = 'Username must not contain spaces';
      } else if (value.length < 3) {
        usernameError = 'Username must be at least 3 characters';
      } else {
        usernameError = null;
      }
    });
  }

  void validateEmail(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        emailError = 'Email is required';
      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(value)) {
        emailError = 'Enter a valid email';
      } else {
        emailError = null;
      }
    });
  }

  void logOut() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    try {
      await authProvider.logout();
      // navigate to the login screen or home page after logout
      Navigator.of(context).pushReplacementNamed('/welcome');
    } catch (e) {
      print(e);
    }
  }

  Widget loadingUserImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[200]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: 130,
            height: 130,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
          ),
        ),
        const Icon(
          Icons.person,
          size: 95,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget loadingTextField() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 18,
            color: Colors.grey[200],
            margin: const EdgeInsets.only(bottom: 2, top: 16),
          ),
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5),
            ),
            margin: const EdgeInsets.only(bottom: 6),
          ),
        ],
      ),
    );
  }

  void showBottomSnackBar(BuildContext context, String text) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 20,
        left: 16,
        right: 16,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
