import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddJournalPage extends StatefulWidget {
  const AddJournalPage({super.key});

  @override
  _AddJournalPageState createState() => _AddJournalPageState();
}

class _AddJournalPageState extends State<AddJournalPage> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  final List<File> images = []; // list to store captured images

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
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 24),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
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
                : const Spacer(),

            // button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // camera button
                    IconButton(
                      onPressed: () async {
                        // open camera to take a picture
                        XFile? capturedImage =
                            await picker.pickImage(source: ImageSource.camera);
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

  void saveEntry() {
    Navigator.pop(context);
  }
}
