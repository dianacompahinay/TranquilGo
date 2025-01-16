import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import intl package

class AddGratitudeLogPage extends StatefulWidget {
  const AddGratitudeLogPage({super.key});

  @override
  _AddGratitudeLogPageState createState() => _AddGratitudeLogPageState();
}

class _AddGratitudeLogPageState extends State<AddGratitudeLogPage> {
  final TextEditingController _contentController = TextEditingController();

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
      backgroundColor: Colors.white,
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
          "New Log",
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
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 24),
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

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
                      hintText: "Write something you're grateful for today...",
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF767676),
                          fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
                ),
              ],
            ),

            //save button
            Positioned(
              bottom: 0,
              right: 0,
              child: ElevatedButton(
                onPressed: saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55AC9F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 68, vertical: 8),
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
            ),
          ],
        ),
      ),
    );
  }
}
