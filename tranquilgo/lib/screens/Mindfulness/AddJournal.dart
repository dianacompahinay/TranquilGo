import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl package

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  _AddJournalPageState createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final TextEditingController _contentController = TextEditingController();

  void pickImage() {
    // logic to pick an image
  }

  void saveEntry() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // format today's date to include the full month name
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 24),
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Container(
                  height: 94,
                  padding: const EdgeInsets.only(top: 55),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Center(
                    child: Text(
                      "New Entry",
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          color: Color(0xFF110000),
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // formatted date
                Text(
                  formattedDate,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF5B5B5B),
                      fontWeight: FontWeight.w500),
                ),

                const Divider(
                  thickness: 1,
                  color: Color(0xFFE1E1E1),
                ),

                // text area
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: "Write something...",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF767676),
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // camera button
                        IconButton(
                          onPressed: pickImage,
                          icon: const Icon(Icons.camera_alt_outlined,
                              size: 30, color: Color(0xFF55AC9F)),
                        ),
                        const SizedBox(width: 10),
                        // image button
                        IconButton(
                          onPressed: pickImage,
                          icon: const Icon(Icons.image_outlined,
                              size: 30, color: Color(0xFF55AC9F)),
                        ),
                      ],
                    ),

                    // save button
                    ElevatedButton(
                      onPressed: saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55AC9F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 68, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // back button
            Positioned(
              top: 52,
              left: 0,
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F7F7),
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
            ),
          ],
        ),
      ),
    );
  }
}
