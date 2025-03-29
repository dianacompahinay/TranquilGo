import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class AddGratitudeLogPage extends StatefulWidget {
  const AddGratitudeLogPage({super.key});

  @override
  _AddGratitudeLogPageState createState() => _AddGratitudeLogPageState();
}

class _AddGratitudeLogPageState extends State<AddGratitudeLogPage> {
  final TextEditingController contentController = TextEditingController();
  bool isLoading = false;

  void saveEntry() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    final userId = FirebaseAuth.instance.currentUser!.uid;
    String result =
        await mindfulnessProvider.addLog(userId, contentController.text);
    if (result != "success") {
      showBottomSnackBar(context, result);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context, 'newLog');
  }

  @override
  Widget build(BuildContext context) {
    // format today's date to include the full month name
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 60,
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
                    controller: contentController,
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
                onPressed: isLoading ? null : saveEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF55AC9F),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 68, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                    : Text(
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
