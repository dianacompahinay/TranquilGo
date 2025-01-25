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

  bool isEditable = false;
  bool isButtonClicked = false;
  bool isPasswordVisible = false;

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
                                child: CircleAvatar(
                                  radius: 65,
                                  backgroundColor: Colors.white,
                                  backgroundImage: profileImage != null
                                      ? FileImage(profileImage!)
                                      : null,
                                  child: profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 95,
                                          color: Color(0xFF73C2C4),
                                        )
                                      : null,
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
                      ? const ChangePassword(userId: '0')
                      : const SizedBox(height: 20),

                  const SizedBox(height: 10),

                  // edit profile button
                  isLoading
                      ? Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (isEditable) {
                                isButtonClicked = true;

                                validateName(nameController.text);
                                validateUsername(usernameController.text);

                                // check validation for all fields
                                bool isValid = nameError == null &&
                                    usernameError == null &&
                                    emailError == null;

                                if (isValid) {
                                  isEditable =
                                      false; // disable editing if valid
                                  isPasswordVisible = false;
                                }
                              } else {
                                isEditable = true; // enable editing
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF55AC9F),
                            minimumSize: const Size(double.infinity, 42),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: DefaultTextStyle(
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(
                                isEditable ? 'Save Changes' : 'Edit Profile'),
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
            obscureText: label == "Password" ? !isPasswordVisible : false,
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
              suffixIcon: label == "Password"
                  ? IconButton(
                      iconSize: 20,
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFBFBFBF),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    )
                  : null,
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
          baseColor: Colors.grey[300]!,
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
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 18,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(bottom: 2, top: 16),
          ),
          Container(
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
            margin: const EdgeInsets.only(bottom: 6),
          ),
        ],
      ),
    );
  }
}
