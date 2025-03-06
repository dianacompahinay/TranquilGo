import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog {
  static void show({
    required BuildContext context,
    required String type,
    required VoidCallback onCancel,
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
                      if (type == "back") {
                        onCancel;
                        Navigator.of(context).pop();
                      }
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

class TrackingPausedDialog extends StatelessWidget {
  final VoidCallback onResume;
  final double speed;

  const TrackingPausedDialog(
      {Key? key, required this.onResume, required this.speed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: Colors.white,
      content: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Average speed',
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                  color: Color(0xFF464646),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: speed.toStringAsFixed(2),
                style: GoogleFonts.inter(
                  color: const Color(0xFF464646),
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: "  km/h",
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF505050),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your speed is faster than a typical walking pace. Please slow down to ensure your activity is properly tracked as walking.",
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                  color: Color(0xFF464646),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.zero,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              onResume(); // call resume function
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(
                  color: Color(0xFFB1B1B1),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  color: Color(0xFF4C4B4B),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
