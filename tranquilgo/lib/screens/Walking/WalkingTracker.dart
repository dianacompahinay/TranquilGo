import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/components/TrackerActionButtons.dart';
import 'package:my_app/components/TrackerConfirmationDialog.dart';
import 'package:image_picker/image_picker.dart';

class WalkingTracker extends StatefulWidget {
  const WalkingTracker({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WalkingTrackerState createState() => _WalkingTrackerState();
}

class _WalkingTrackerState extends State<WalkingTracker> {
  final List<XFile> capturedImages = []; // list to store captured images
  final ImagePicker picker = ImagePicker();

  XFile? capturedImage;

  String buttonState = 'start';
  bool showMap = true;
  double progress = 0.675;
  int targetSteps = 1000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ConfirmationDialog.show(
                context: context,
                type: "back",
              );
            },
          ),
        ),
        title: Text(
          "Walking Tracker",
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
      body: Column(
        children: [
          showMap
              ? Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: Color(0xFFECECEC),
                              width: 8,
                            ),
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/temp-map.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 18,
                        right: 18,
                        child: GestureDetector(
                          onTap: () async {
                            // Open camera to take a picture
                            capturedImage = await picker.pickImage(
                                source: ImageSource.camera);
                            if (capturedImage != null) {
                              capturedImages.add(capturedImage!);
                              // ignore: use_build_context_synchronously
                              showTopSnackBar(context);
                            }
                          },
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.25),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1.2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black54,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Column(
                          children: [
                            buildMetricsCard("Steps", "675", "large"),
                            buildMetricsCard(
                                "Distance covered", "0.5", "large"),
                            buildMetricsCard("Time", "0:08:12", "large"),
                            Container(
                              padding: const EdgeInsets.all(2),
                              width: 150,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // open camera to take a picture
                                  capturedImage = await picker.pickImage(
                                      source: ImageSource.camera);
                                  if (capturedImage != null) {
                                    setState(() {
                                      capturedImages.add(capturedImage!);
                                    });
                                    // ignore: use_build_context_synchronously
                                    showTopSnackBar(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF8F8F8),
                                  minimumSize: const Size(60, 38),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: DefaultTextStyle(
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.black38,
                                        size: 18,
                                      ),
                                      SizedBox(width: 5),
                                      Text('Take a Photo'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                showMap
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildMetricsCard("Steps", "675", "small"),
                          buildMetricsCard("Time", "0:08:12", "small"),
                          buildMetricsCard("Distance covered", "0.5", "small"),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress Bar",
                        style: GoogleFonts.manrope(
                          textStyle: const TextStyle(
                            color: Color(0xFF444444),
                            fontWeight: FontWeight.w400,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                height: 20,
                                width: 20,
                                'assets/icons/footprint.png',
                                fit: BoxFit.contain,
                                color: const Color(0xFF6DA899),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                "$targetSteps",
                                style: GoogleFonts.manrope(
                                  textStyle: const TextStyle(
                                    color: Color(0xFF484848),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Baseline(
                                baseline: 18,
                                baselineType: TextBaseline.alphabetic,
                                child: Text(
                                  "target steps",
                                  style: GoogleFonts.manrope(
                                    textStyle: const TextStyle(
                                      color: Color(0xFF7D7D7D),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "${(progress * 100).toStringAsFixed(1)}%",
                            style: GoogleFonts.manrope(
                              textStyle: const TextStyle(
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        backgroundColor: const Color(0xFFEBECEC),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF55AC9F)),
                      ),
                    ],
                  ),
                ),

                // action buttons
                const SizedBox(height: 40),
                getActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMetricsCard(String label, String value, String type) {
    return Expanded(
      child: Container(
        height: 96,
        width: double.infinity,
        margin: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8F8),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                textStyle: TextStyle(
                  color: const Color(0xFF484848),
                  fontWeight: FontWeight.w500,
                  fontSize: type == "small" ? 12 : 16,
                ),
              ),
            ),
            const SizedBox(height: 5),
            label == "Distance covered"
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.manrope(
                          textStyle: TextStyle(
                            color: const Color(0xFF535353),
                            fontWeight: FontWeight.w600,
                            fontSize: type == "small" ? 22 : 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Baseline(
                        baseline: type == "small" ? 22 : 32,
                        baselineType: TextBaseline.alphabetic,
                        child: Text(
                          "Km",
                          style: GoogleFonts.manrope(
                            textStyle: TextStyle(
                              color: const Color(0xFF535353),
                              fontWeight: FontWeight.w500,
                              fontSize: type == "small" ? 11 : 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: GoogleFonts.manrope(
                      textStyle: TextStyle(
                        color: const Color(0xFF535353),
                        fontWeight: FontWeight.w600,
                        fontSize: type == "small" ? 22 : 32,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget getActionButtons() {
    return ActionButtons(
      buttonState: buttonState,
      onStart: () {
        setState(() {
          buttonState = 'pause';
        });
      },
      onPause: () {
        setState(() {
          buttonState = 'resume';
        });
      },
      onResume: () {
        setState(() {
          buttonState = 'pause';
        });
      },
      onFinish: () => ConfirmationDialog.show(
        context: context,
        type: "zero_steps",
      ),
      onSwitchMap: () {
        setState(() {
          showMap = !showMap;
        });
      },
      progress: progress,
      capturedImages: capturedImages,
    );
  }

  void showTopSnackBar(BuildContext context) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        left: 10,
        right: 10,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2BB1C0),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Text(
              "Photo successfully taken!",
              style: TextStyle(
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
}
