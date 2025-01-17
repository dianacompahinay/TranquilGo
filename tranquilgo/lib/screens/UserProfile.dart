import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Auth/LandingPage.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // for error messages
  String? usernameError;
  String? emailError;
  String? passwordError;

  bool isEditable = false;
  bool isButtonClicked = false;

  @override
  void initState() {
    super.initState();
    // initialize text controllers with default values
    usernameController = TextEditingController(text: "username123");
    emailController = TextEditingController(text: "username123@gmail.com");
    passwordController = TextEditingController(text: "********");
  }

  @override
  void dispose() {
    // dispose text controllers when widget is removed
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 40),

                  // profile icon
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFACACAC),
                          width: 1,
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 95,
                          color: Color(0xFF73C2C4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // username field
                  buildField(
                    "Username",
                    "Enter username",
                    usernameError,
                    usernameController,
                    validateUsername,
                  ),

                  // email field
                  buildField(
                    "Email",
                    "Enter email",
                    emailError,
                    emailController,
                    validateEmail,
                  ),

                  // password field
                  buildField(
                    "Password",
                    "Enter password",
                    passwordError,
                    passwordController,
                    validatePassword,
                  ),

                  const SizedBox(height: 60),

                  // edit profile button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isEditable) {
                          isButtonClicked = true;

                          validateUsername(usernameController.text);
                          validateEmail(emailController.text);
                          validatePassword(passwordController.text);

                          // check validation for all fields
                          bool isValid = usernameError == null &&
                              emailError == null &&
                              passwordError == null;

                          if (isValid) {
                            isEditable = false; // disable editing if valid
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
                      child: Text(isEditable ? 'Save Changes' : 'Edit Profile'),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // log out button
                  Center(
                    child: InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LandingPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            obscureText: label == "Password" ? true : false,
            enabled: isEditable,
            style: GoogleFonts.inter(
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isEditable
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

  void validateUsername(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        usernameError = 'username is required';
      } else if (value.length < 3) {
        usernameError = 'username must be at least 3 characters';
      } else {
        usernameError = null;
      }
    });
  }

  void validateEmail(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        emailError = 'email is required';
      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(value)) {
        emailError = 'enter a valid email';
      } else {
        emailError = null;
      }
    });
  }

  void validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = 'password is required';
      } else if (value.length < 8) {
        passwordError = 'password must be at least 8 characters';
      } else {
        passwordError = null;
      }
    });
  }
}
