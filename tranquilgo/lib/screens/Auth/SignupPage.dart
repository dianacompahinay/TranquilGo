import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/AuthProvider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool isButtonClicked = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? nameError;
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchExistingUsernamesAndEmails();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB8E5DA),
              Color(0xFF90CDC6),
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 140.0, left: 25.0, right: 25.0),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            DefaultTextStyle(
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xFF5B84C2),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Create Account'),
                            ),
                            buildTextField(
                              "Name",
                              nameController,
                              nameError,
                              validateName,
                            ),
                            buildTextField(
                              "Username",
                              usernameController,
                              usernameError,
                              validateUsername,
                            ),
                            buildTextField(
                              "Email",
                              emailController,
                              emailError,
                              validateEmail,
                            ),
                            buildTextField(
                              "Password",
                              passwordController,
                              passwordError,
                              validatePassword,
                            ),
                            buildTextField(
                              "Confirm Password",
                              confirmPasswordController,
                              confirmPasswordError,
                              validateConfirmPassword,
                            ),
                            const SizedBox(height: 38),

                            // sign up button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          isButtonClicked = true;
                                        });

                                        handleSignUp(context);
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF55AC9F),
                                  minimumSize: const Size(double.infinity, 42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 4,
                                        ),
                                      )
                                    : DefaultTextStyle(
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            color: Color(0xFFFFFFFF),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        child: const Text('Sign up'),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: DefaultTextStyle(
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF494949),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text('Already have an account'),
                              ),
                            ),
                            const SizedBox(height: 26),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // back button
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 25.0,
              child: Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFDEF3E7).withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset(
                      'assets/images/back-arrow.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String hintText,
    TextEditingController controller,
    String? errorText,
    Function(String) validator,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 24.0),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          // remove error text when the user types
          validator(value);
        },
        obscureText: hintText == "Password"
            ? !isPasswordVisible
            : hintText == "Confirm Password"
                ? !isConfirmPasswordVisible
                : false,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: isButtonClicked ? errorText : null,
          hintStyle: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF919191),
            ),
          ),
          suffixIcon: hintText == "Password"
              ? IconButton(
                  iconSize: 20,
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFFBFBFBF),
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : hintText == "Confirm Password"
                  ? IconButton(
                      iconSize: 20,
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFFBFBFBF),
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    )
                  : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 18.0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFC1C1C1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFF55AC9F),
              width: 2.0,
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

  void handleSignUp(BuildContext context) async {
    validateName(nameController.text);
    validateUsername(usernameController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    validateConfirmPassword(confirmPasswordController.text);

    if (nameError == null &&
        usernameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null) {
      setState(() {
        isLoading = true;
      });

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signUp(
          name: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
        String success = "A new account has been successfully created.";
        showBottomSnackBar(context, success);
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        showBottomSnackBar(
            context, 'An unexpected error occurred. Please try again later.');
        print('Error: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      if (value.trim().isEmpty) {
        usernameError = 'Username is required';
      } else if (value.contains(' ')) {
        usernameError = 'Username must not contain spaces';
      } else if (value.length < 3) {
        usernameError = 'Username must be at least 3 characters';
      } else if (authProvider.usernames.contains(value)) {
        usernameError = 'Username is already taken';
      } else {
        usernameError = null;
      }
    });
  }

  void validateEmail(String value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      if (value.trim().isEmpty) {
        emailError = 'Email is required';
      } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
          .hasMatch(value)) {
        emailError = 'Enter a valid email';
      } else if (authProvider.emails.contains(value)) {
        emailError = 'Email is already registered';
      } else {
        emailError = null;
      }
    });
  }

  void validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        passwordError = 'Password is required';
      } else if (value.contains(' ')) {
        passwordError = 'Password must not contain spaces';
      } else if (value.length < 8) {
        passwordError = 'Password must be at least 8 characters';
      } else {
        passwordError = null;
      }
    });
  }

  void validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        confirmPasswordError = 'Confirm password is required';
      } else if (value != passwordController.text) {
        confirmPasswordError = 'Passwords do not match';
      } else {
        confirmPasswordError = null;
      }
    });
  }
}
