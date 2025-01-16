import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog {
  static void show({
    required BuildContext context,
    required String type,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
          content: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              type == "back"
                  ? "Are you sure you want to leave? Any recorded data will be lost."
                  : "No progress has been made (zero steps). Do you want to continue or discard your progress?",
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  color: Color(0xFF464646),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Container(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      if (type == "zero_steps") Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(120, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(
                          color: Color(0xFFB1B1B1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      type == "back" ? 'No' : 'Discard',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Color(0xFF4C4B4B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close dialog
                      if (type == "back") Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF55AC9F),
                      minimumSize: const Size(120, 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      type == "back" ? 'Yes' : 'Continue',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
