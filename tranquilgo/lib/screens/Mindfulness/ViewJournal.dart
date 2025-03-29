import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:provider/provider.dart';

class ViewJournalPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ViewJournalPage({super.key, this.arguments});

  @override
  _ViewJournalPageState createState() => _ViewJournalPageState();
}

class _ViewJournalPageState extends State<ViewJournalPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  TextEditingController contentController = TextEditingController();

  String? entryId;
  String? date;
  List<String> images = [];
  String? content;
  String? updatedAt;

  bool isEditable = false;
  bool isLoading = false;
  bool isUpdated = false;

  @override
  void initState() {
    super.initState();

    // load arguments if available
    if (widget.arguments != null) {
      setState(() {
        entryId = widget.arguments?['entryId'];
        date = widget.arguments?['date'];
        images = List<String>.from(widget.arguments?['images'] ?? []);
        contentController.text = widget.arguments?['content'] ?? "";
        updatedAt = widget.arguments?['updatedAt'];
      });
    }
  }

  void saveEntry() async {
    final mindfulnessProvider =
        Provider.of<MindfulnessProvider>(context, listen: false);
    setState(() {
      isLoading = true;
      isUpdated = true;
      isEditable = false;
    });

    String result = await mindfulnessProvider.editEntry(
        userId, entryId!, images, contentController.text);
    if (result != "success") {
      setState(() {
        isUpdated = false;
      });
      showBottomSnackBar(context, result);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mindfulnessProvider = Provider.of<MindfulnessProvider>(context);
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
              if (isUpdated) {
                Navigator.pop(context, 'entryUpdated');
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        title: Text(
          "Journal",
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Color(0xFF110000),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Color(0xFF767676),
                size: 24,
              ),
              onSelected: (value) async {
                if (value == 'Edit') {
                  setState(() {
                    isEditable = true;
                  });
                } else if (value == 'Delete') {
                  String result =
                      await mindfulnessProvider.deleteEntry(userId, entryId!);
                  if (result != "success") {
                    showBottomSnackBar(context, result);
                  }
                  Navigator.pop(context, 'entryDeleted');
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'Edit',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      'Edit',
                      style: TextStyle(color: Color(0xFF606060)),
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'Delete',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFF606060)),
                    ),
                  ),
                ),
              ],
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding:
            const EdgeInsets.only(left: 26, right: 26, top: 10, bottom: 16),
        decoration: const BoxDecoration(color: Colors.white),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),

                        // formatted date
                        Text(
                          date!,
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF5B5B5B),
                              fontWeight: FontWeight.w500),
                        ),

                        const Divider(
                          thickness: 1,
                          color: Color(0xFFE1E1E1),
                        ),

                        if (images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    images.asMap().entries.map<Widget>((entry) {
                                  int index = entry.key;
                                  String imagePath = entry.value;

                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            showImageModal(File(imagePath)),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 2, right: 8),
                                          width: 160,
                                          height: 220,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Builder(
                                              builder: (context) {
                                                File imageFile =
                                                    File(imagePath);

                                                if (imageFile.existsSync()) {
                                                  return Image.file(
                                                    imageFile, // load from local file
                                                    fit: BoxFit.cover,
                                                  );
                                                } else {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: Center(
                                                      child: Icon(
                                                        // file is missing
                                                        Icons.broken_image,
                                                        color: Colors.grey[600],
                                                        size: 50,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (isEditable)
                                        Positioned(
                                          right: 16,
                                          top: 12,
                                          child: GestureDetector(
                                            onTap: () => removeImage(index),
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black87
                                                    .withOpacity(0.3),
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
                                  );
                                }).toList(),
                              ),
                            ),
                          ),

                        SizedBox(
                          child: TextField(
                            controller: contentController,
                            readOnly: !isEditable,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: isEditable ? "Write something..." : "",
                              hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color(0xFF767676),
                                  fontWeight: FontWeight.w400),
                              border: InputBorder.none,
                            ),
                            style: GoogleFonts.poppins(
                                fontSize: 14.5, color: const Color(0xFF5B5B5B)),
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (!isUpdated && updatedAt != null && !isEditable)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 3,
                    child: Center(
                      child: Text("Updated last: $updatedAt",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              color: Color(0xFF979797),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          textAlign: TextAlign.center),
                    ),
                  ),
                // button row
                if (isEditable)
                  Positioned(
                    right: 2,
                    bottom: 0,
                    child:
                        // save button
                        ElevatedButton(
                      onPressed: isLoading ? null : saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF55AC9F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 68, vertical: 8),
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
            );
          },
        ),
      ),
    );
  }

  void showImageModal(File imageFile) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Builder(
              builder: (context) {
                if (imageFile.existsSync()) {
                  return Image.file(
                    imageFile, // load from local file
                    fit: BoxFit.cover,
                  );
                } else {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        // file is missing
                        Icons.broken_image,
                        color: Colors.grey[600],
                        size: 50,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
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
