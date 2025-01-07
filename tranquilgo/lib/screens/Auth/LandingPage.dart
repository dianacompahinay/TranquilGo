import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // background image
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/landing-page.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 22.0, right: 22.0, top: 50.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: GoogleFonts.righteous(
                  textStyle: TextStyle(
                    color: const Color(0xFF55AC9F),
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.8),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                child: const Text('TranquilGo'),
              ),
              const SizedBox(height: 5),
              DefaultTextStyle(
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                      color: Color(0xFF2C2C2C),
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic),
                ),
                child: const Text('Welcome to your Path to Wellness'),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 120.0, left: 25.0, right: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // login button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55AC9F),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
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
                        child: const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // signup button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDFDFD),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: DefaultTextStyle(
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Color(0xFF646464),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Sign up'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
