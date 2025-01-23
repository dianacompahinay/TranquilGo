import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/AuthProvider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isButtonClicked = false;
  bool isLoading = false;
  bool isPasswordVisible = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? usernameError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchExistingUsernamesAndEmails();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // background gradient
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
                      // white container for login
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
                            // title text
                            DefaultTextStyle(
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: Color(0xFF5B84C2),
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Login'),
                            ),
                            // username field
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0, top: 40.0),
                              child: TextField(
                                controller: usernameController,
                                onChanged: (value) {
                                  // remove error text when the user types
                                  validateAndLogin(context);
                                },
                                decoration: InputDecoration(
                                  hintText: "Username",
                                  errorText:
                                      isButtonClicked ? usernameError : null,
                                  hintStyle: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF919191),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 18.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFC1C1C1)),
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
                            ),
                            // password field
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0, top: 24.0),
                              child: TextField(
                                controller: passwordController,
                                onChanged: (value) {
                                  // remove error text when the user types
                                  validateAndLogin(context);
                                },
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  errorText:
                                      isButtonClicked ? passwordError : null,
                                  hintStyle: GoogleFonts.poppins(
                                    textStyle: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF919191),
                                    ),
                                  ),
                                  suffixIcon: IconButton(
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
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 18.0,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFC1C1C1)),
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
                            ),
                            const SizedBox(height: 42),

                            // sign in button
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 40.0, right: 40.0),
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          isButtonClicked = true;
                                        });
                                        validateAndLogin(context);
                                        handleLogin(context);
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
                                        child: const Text('Sign in'),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // signup link
                            InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: DefaultTextStyle(
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF494949),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: const Text('Create new account'),
                              ),
                            ),
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

  Future<void> validateAndLogin(BuildContext context) async {
    setState(() {
      usernameError = null;
      passwordError = null;
    });

    String username = usernameController.text.trim();
    String password = passwordController.text;

    // check for empty fields
    if (username.isEmpty) {
      setState(() {
        usernameError = 'Username is required';
      });
    }
    if (password.isEmpty) {
      setState(() {
        passwordError = 'Password is required';
      });
    }
  }

  void handleLogin(BuildContext context) async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (passwordError == null && usernameError == null) {
      setState(() {
        isLoading = true;
      });
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final result = await authProvider.login(username, password);

        if (result == 'success') {
          // navigate to the next screen on success
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // show error message in snackbar
          showBottomSnackBar(context, result);
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
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
