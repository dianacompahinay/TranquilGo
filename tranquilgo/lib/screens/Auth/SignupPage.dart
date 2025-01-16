import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
            ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(top: 90.0, left: 25.0, right: 25.0),
                  child: Stack(
                    children: [
                      // main content container
                      Container(
                        // white background
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 140,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                        ),
                        child: SingleChildScrollView(
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
                                child: const Text('Create Account'),
                              ),

                              // username textfield
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 40.0, right: 40.0, top: 40.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Username",
                                    hintStyle: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Color(
                                            0xFF919191), // Hint text color
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
                                  ),
                                ),
                              ),

                              // email textfield
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 40.0, right: 40.0, top: 24.0),
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
                                        color: Color(
                                            0xFF919191), // Hint text color
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
                                  ),
                                ),
                              ),

                              // confirm password textfield
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 40.0, right: 40.0, top: 24.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    hintStyle: GoogleFonts.poppins(
                                      textStyle: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                        color: Color(
                                            0xFF919191), // Hint text color
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
                                  ),
                                ),
                              ),

                              const SizedBox(height: 38),

                              // sign in button
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 40.0, right: 40.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF55AC9F),
                                      minimumSize:
                                          const Size(double.infinity, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
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
                                      child: const Text('Sign up'),
                                    ),
                                  )),

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
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text('Already have an account'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
}
