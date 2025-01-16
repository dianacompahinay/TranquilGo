import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Getstarted extends StatelessWidget {
  const Getstarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 75),
                  Container(
                    height: 400,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/get-started.png'),
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 25.0, right: 45.0, top: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DefaultTextStyle(
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 23,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Take the First Step',
                                textAlign: TextAlign.left),
                          ),
                          const SizedBox(height: 5),
                          DefaultTextStyle(
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text(
                                'Embrace the journey ahead. Every step brings you closer to a stronger, healthier version of yourself.',
                                textAlign: TextAlign.left),
                          ),
                        ],
                      )),
                ],
              ),
              Positioned(
                bottom: 40.0,
                left: 25.0,
                right: 25.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
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
                    child: const Text('Get Started'),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
