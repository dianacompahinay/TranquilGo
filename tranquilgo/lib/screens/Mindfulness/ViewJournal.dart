import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ViewJournalPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const ViewJournalPage({super.key, this.arguments});

  @override
  _ViewJournalPageState createState() => _ViewJournalPageState();
}

class _ViewJournalPageState extends State<ViewJournalPage> {
  TextEditingController contentController = TextEditingController();
  bool isEditable = false;

  String? entryId;
  DateTime? date;
  List<String> images = [];
  String? content;

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(date!);

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
              onSelected: (value) {
                if (value == 'Edit') {
                  setState(() {
                    isEditable = true;
                  });
                } else if (value == 'Delete') {
                  // delete entry
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
                                            image: DecorationImage(
                                                image: AssetImage(imagePath),
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                      if (isEditable)
                                        Positioned(
                                          right: 16,
                                          top: 12,
                                          child: GestureDetector(
                                            onTap: () => removeImage(
                                                index), // remove image at index
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
                // button row
                if (isEditable)
                  Positioned(
                    right: 2,
                    bottom: 0,
                    child:
                        // save button
                        ElevatedButton(
                      onPressed: () {
                        saveEntry();
                        setState(() {
                          isEditable = false;
                        });
                      },
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
                  ),
              ],
            );
          },
        ),
      ),
    );
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
    // Navigator.pop(context);
  }
}
