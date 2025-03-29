import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:provider/provider.dart';

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  _AddJournalPageState createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final TextEditingController contentController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final List<File> images = []; // list to store captured images
  bool isLoading = false;

  void saveEntry() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);

    setState(() {
      isLoading = true;
    });
    final userId = FirebaseAuth.instance.currentUser!.uid;
    String result = await mindfulnessProvider.addEntry(
        userId, images, contentController.text);
    if (result != "success") {
      showBottomSnackBar(context, result);
    }
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context, 'newEntry');
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
          "New Entry",
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
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

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

            images.isNotEmpty
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // loop through the images list to dynamically add containers
                        for (int i = 0; i < images.length; i++)
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 12, bottom: 8),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => showImageModal(images[i]),
                                  child: Container(
                                    width: 75,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: FileImage(images[i]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: GestureDetector(
                                    onTap: () =>
                                        removeImage(i), // remove image at index
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black87.withOpacity(0.3),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(),

            // button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // camera button
                    IconButton(
                      onPressed: images.length >= 3
                          ? () {
                              showBottomSnackBar(
                                  context, "Cannot exceed to 3 images.");
                            }
                          : () async {
                              // open camera to take a picture
                              final ImagePicker picker = ImagePicker();
                              XFile? capturedImage = await picker.pickImage(
                                source: ImageSource.camera,
                                preferredCameraDevice: CameraDevice.rear,
                                imageQuality: 85,
                              );
                              if (capturedImage != null) {
                                File imageFile = File(capturedImage.path);
                                setState(() {
                                  images.add(imageFile);
                                });
                              }
                            },
                      icon: const Icon(Icons.camera_alt_outlined,
                          size: 30, color: Color(0xFF55AC9F)),
                    ),
                    const SizedBox(width: 10),
                    // image button
                    IconButton(
                      onPressed: images.length >= 3
                          ? () {
                              showBottomSnackBar(
                                  context, "Cannot exceed to 3 images.");
                            }
                          : pickImage,
                      icon: const Icon(Icons.image_outlined,
                          size: 30, color: Color(0xFF55AC9F)),
                    ),
                  ],
                ),

                // save button
                ElevatedButton(
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  void showImageModal(File image) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image(
              image: FileImage(image),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
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
