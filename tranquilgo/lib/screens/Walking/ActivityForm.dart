import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/providers/TrackerProvider.dart';
import 'dart:math';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/providers/MindfulnessProvider.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class ActivityForm extends StatefulWidget {
  final Timestamp startTime;
  final Timestamp endTime;
  final int steps;
  final int duration;
  final double distance;
  final List<XFile> capturedImages;

  const ActivityForm({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.steps,
    required this.duration,
    required this.distance,
    required this.capturedImages,
  });

  @override
  State<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends State<ActivityForm> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  MindfulnessProvider mindfulnessProvider = MindfulnessProvider();

  late int steps = widget.steps;
  late int duration = widget.duration;
  late double distance = widget.distance;
  late Timestamp startTime = widget.startTime;
  late Timestamp endTime = widget.endTime;
  late List<XFile> capturedImages = widget.capturedImages;

  final List<File> images = []; // list to store images
  final TextEditingController reflectionJournalController =
      TextEditingController();
  final TextEditingController gratitudeController = TextEditingController();

  int? confidenceLevel;
  int? selectedMood;

  bool isButtonClicked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.resetValues(userId);
    trackerProvider.disposeService();

    // convert XFile in File type
    for (var img in capturedImages) {
      File imageFile = File(img.path);
      setState(() {
        images.add(imageFile);
      });
    }
  }

  void onSave() async {
    final activityProvider =
        Provider.of<ActivityProvider>(context, listen: false);

    setState(() {
      isButtonClicked = true;
    });

    bool hasError = false;

    if (confidenceLevel != null && selectedMood != null) {
      setState(() {
        isLoading = true;
      });

      DateTime date = DateTime.now();

      String result1 = await activityProvider.createActivity(
        userId,
        date,
        startTime,
        endTime,
        duration,
        steps,
        distance,
        confidenceLevel! + 1,
        selectedMood! + 1,
      );

      // plus 1 since selectedMood is index but mood is 1 to 5
      String result2 =
          await mindfulnessProvider.saveMoodRecord(userId, selectedMood! + 1);
      if (result1 != "success" || result2 != "success") {
        hasError = true;
      }

      if (reflectionJournalController.text.trim().isNotEmpty ||
          images.isNotEmpty) {
        String result = await mindfulnessProvider.addEntry(
            userId, images, reflectionJournalController.text);
        if (result != "success") {
          hasError = true;
        }
      }

      if (gratitudeController.text.trim().isNotEmpty) {
        String result =
            await mindfulnessProvider.addLog(userId, gratitudeController.text);
        if (result != "success") {
          hasError = true;
        }
      }

      if (hasError) {
        showSnackBar(context,
            "Unexpected error occurred while saving activity details.");
      } else {
        showSnackBar(context, getRandomMotivationalMessage());
      }

      setState(() {
        isLoading = false;
      });

      // close the page and return to the main page
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          false, // prevent going back, needs to accomplish the form first
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 60,
              title: Text(
                "Walking Completed",
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Color(0xFF110000),
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ),
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              floating: false,
              pinned: false,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recorded Activity",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF494949),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            infoCard("Steps", "$steps"),
                            const SizedBox(width: 10),
                            infoCard("Time", formatDuration(duration)),
                            const SizedBox(width: 10),
                            infoCard("Distance", roundOffDouble(distance, 2)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text:
                                "How confident are you in completing a similar training next week, despite its duration?",
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: const Color(0xFF555555),
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              isButtonClicked && confidenceLevel == null
                                  ? TextSpan(
                                      text: "  * Required",
                                      style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFFC14040)),
                                    )
                                  : const TextSpan(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Not able\nat all",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF535353),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                4,
                                (index) => Column(
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue: confidenceLevel,
                                      onChanged: (value) {
                                        setState(() {
                                          confidenceLevel = value!;
                                        });
                                      },
                                      activeColor: const Color(0xFF55AC9F),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(0, -6),
                                      child: Text(
                                        "${index + 1}",
                                        style: GoogleFonts.manrope(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF535353),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              "Absolutely\nable",
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF535353),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Reflection",
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 17,
                              color: Color(0xFF494949),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  text: "How do you feel after your walk?",
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  children: [
                                    isButtonClicked && selectedMood == null
                                        ? TextSpan(
                                            text: "  * Required",
                                            style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFFC14040)),
                                          )
                                        : const TextSpan(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List.generate(
                                  5,
                                  (index) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedMood = index;
                                        });
                                      },
                                      child: Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selectedMood == index
                                              ? const Color(0xFF55AC9F)
                                              : const Color(0xFFFFFFFF),
                                        ),
                                        child: Image.asset(
                                          'assets/icons/mood-${index + 1}.png',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.contain,
                                        ),
                                      )),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Photos",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // loop through the images list to dynamically add containers
                                    for (int i = 0; i < images.length; i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 12),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 90,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                image: DecorationImage(
                                                  image: FileImage(images[i]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 5,
                                              top: 5,
                                              child: GestureDetector(
                                                onTap: () => removeImage(
                                                    i), // remove image at index
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
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
                                        ),
                                      ),
                                    GestureDetector(
                                      onTap: pickImage,
                                      child: Container(
                                        width: 80,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color(0xFFF3F3F3),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.camera_alt_outlined,
                                              color: Color(0xFF989898),
                                              size: 20,
                                            ),
                                            Text(
                                              "Upload\nPhoto",
                                              style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFFA4A4A4),
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.2,
                                                ),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Let's write about it (optional)",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: reflectionJournalController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF868686),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF55AC9F),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "What's one thing you're grateful for today? (optional)",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF555555),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: gratitudeController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF868686),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF55AC9F),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: isLoading ? null : onSave,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: const Color(0xFF55AC9F),
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
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
                                    : Center(
                                        child: Text(
                                          "Save",
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget infoCard(String label, String value) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: const Color(0xFF919191),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                textStyle: const TextStyle(
                  color: Color(0xFF484848),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            label == "Distance"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: Color(0xFF535353),
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Baseline(
                        baseline: 22,
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          "Km",
                          style: GoogleFonts.manrope(
                            textStyle: const TextStyle(
                              color: Color(0xFF535353),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: const TextStyle(
                        color: Color(0xFF535353),
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
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

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    return "${hours.toString()}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  String roundOffDouble(double value, int decimals) {
    return value
        .toStringAsFixed(decimals)
        .replaceAll(RegExp(r"0*$"), "")
        .replaceAll(RegExp(r"\.$"), "");
  }

  void showSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).padding.bottom + 80,
        left: 8,
        right: 8,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              message,
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

    // insert and auto remove the snackbar after 3 seconds
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  String getRandomMotivationalMessage() {
    final List<String> messages = [
      "Great job! Keep moving forward.",
      "Every step counts. Awesome work!",
      "You're unstoppable! Keep it up.",
      "What an achievement! Well done!",
      "Your journey inspires! Keep going!",
      "You're doing fantastic! Stay strong!",
      "Way to go! Keep smashing those goals!",
      "Walking your way to greatness!",
      "Keep walking, you're doing amazing!",
      "Great strides! You're incredible!",
      "Your effort is paying off!",
      "Stay determined, you're awesome!",
      "Proud of your progress!",
      "Sweat is just fat crying. Keep it up!",
      "Your future self is thanking you.",
      "Strive for progress, not perfection.",
      "One step at a time, you're getting there."
    ];

    final random = Random();
    return messages[random.nextInt(messages.length)];
  }
}
