import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
                  padding: const EdgeInsets.only(
                      top: 140.0, left: 25.0, right: 25.0),
                  child: Stack(
                    children: [
                      // main content container
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              // white background
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                              ),
                              child: Column(
                                //content
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
                                    child: const Text('Login'),
                                  ),

                                  // email textfield
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 40.0, right: 40.0, top: 40.0),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Email",
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF919191),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 0.0,
                                          horizontal: 18.0,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFC1C1C1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF55AC9F),
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // password textfield
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 40.0, right: 40.0, top: 24.0),
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF919191),
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 0.0,
                                          horizontal: 18.0,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFC1C1C1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF55AC9F),
                                            width: 2.0,
                                          ),
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
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/firstgoal');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF55AC9F),
                                          minimumSize:
                                              const Size(double.infinity, 40),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        child: DefaultTextStyle(
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          child: const Text('Sign in'),
                                        ),
                                      )),

                                  const SizedBox(height: 16),
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
                        ],
                      ),
                    ],
                  ),
                ),
                // back button
                Positioned(
                  top: 60.0,
                  left: 25.0,
                  child: Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDEF3E7),
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
            )));
  }
}
