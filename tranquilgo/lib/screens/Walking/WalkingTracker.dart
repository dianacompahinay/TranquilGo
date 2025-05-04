import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/components/TrackerActionButtons.dart';
import 'package:my_app/components/TrackerConfirmationDialog.dart';
import 'package:my_app/components/MapScreen.dart';

import 'dart:async';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/TrackerProvider.dart';
import 'package:my_app/providers/ActivityProvider.dart';

class WalkingTracker extends StatefulWidget {
  const WalkingTracker({super.key});

  @override
  _WalkingTrackerState createState() => _WalkingTrackerState();
}

class _WalkingTrackerState extends State<WalkingTracker> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final List<XFile> capturedImages = []; // list to store captured images
  final ImagePicker picker = ImagePicker();
  XFile? capturedImage;

  Timer? locationTimer;
  String buttonState = 'start';
  bool isFinish = false;
  bool showMap = true;

  OverlayEntry? overlayEntryRoute;
  bool overlayShown = false; // prevent multiple overlays
  bool suggestRoute = false;

  bool isDialogShowing = false;

  @override
  void initState() {
    super.initState();

    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);
    trackerProvider.requestPlatformPermissions();
    trackerProvider.resetValues(userId);
    trackerProvider.pauseTracking();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Geolocator.isLocationServiceEnabled().then((isGPSEnabled) {
          if (isGPSEnabled) {
            trackerProvider.fetchCurrentLocation();
          }
        });
      }
    });

    // schedule the timer after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && trackerProvider.currentLocation == null) {
          setState(() {
            showMap = false;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);
    // listen for GPS status changes
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        trackerProvider.fetchCurrentLocation();
        setState(() {
          showMap = true;
        });
      }
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackerProvider = Provider.of<TrackerProvider>(context);
    final activityProvider = Provider.of<ActivityProvider>(context);

    void handleSuggestRouteSelection(bool useSuggestedRoute) {
      setState(() {
        suggestRoute = useSuggestedRoute;
      });
    }

    // show the overlay once when currentLocation is obtained
    if (trackerProvider.currentLocation != null && !overlayShown) {
      overlayShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isFinish) {
          // to prevent inserting the overlay when finish already within few seconds
          selectRouteConfirmation(context, handleSuggestRouteSelection);
        }
      });
    }

    // show dialog when tracking is paused due to high speed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (trackerProvider.isTrackingPaused && !isDialogShowing) {
        setState(() {
          isDialogShowing = true;
        });
        showDialog(
          context: context,
          builder: (_) => TrackingPausedDialog(
            onResume: () {
              trackerProvider.resumeTracking();
              setState(() {
                isDialogShowing = false;
              });
            },
            speed: trackerProvider.currentSpeed,
          ),
        );
      }
    });

    return WillPopScope(
      onWillPop: () async {
        if (trackerProvider.progress == 0) {
          Navigator.pop(context);
          removeOverlay();
        } else {
          ConfirmationDialog.show(
            context: context,
            type: "back",
            onCancel: () {
              trackerProvider.resetValues(userId);
              trackerProvider.pauseTracking();
              trackerProvider.disposeService();
              removeOverlay();
            },
          );
        }
        return false; // prevent default back action
      },
      child: Scaffold(
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
                if (trackerProvider.progress == 0) {
                  Navigator.pop(context);
                  removeOverlay();
                } else {
                  ConfirmationDialog.show(
                    context: context,
                    type: "back",
                    onCancel: () {
                      trackerProvider.resetValues(userId);
                      trackerProvider.pauseTracking();
                      trackerProvider.disposeService();
                      removeOverlay();
                    },
                  );
                }
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
                          child: MapScreen(
                            targetSteps: activityProvider.goalSteps,
                            isSuggestRouteEnabled: suggestRoute,
                          ),
                        ),
                        Positioned(
                          bottom: 18,
                          right: 18,

                          // for camera button
                          child: GestureDetector(
                            onTap: () async {
                              // open camera to take a picture
                              capturedImage = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (capturedImage != null) {
                                capturedImages.add(capturedImage!);
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
                              buildMetricsCard("Steps",
                                  "${trackerProvider.stepCount}", "large"),
                              buildMetricsCard(
                                  "Distance covered",
                                  trackerProvider.distance.toStringAsFixed(3),
                                  "large"),
                              buildMetricsCard(
                                  "Time", trackerProvider.displayTime, "large"),
                              Container(
                                padding: const EdgeInsets.all(2),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // open camera to take a picture
                                    capturedImage = await picker.pickImage(
                                        source: ImageSource.camera);
                                    if (capturedImage != null) {
                                      setState(() {
                                        capturedImages.add(capturedImage!);
                                      });
                                      showTopSnackBar(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.3,
                                    backgroundColor: const Color(0xFFF8F8F8),
                                    minimumSize:
                                        const Size(double.infinity, 40),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                  showMap && trackerProvider.currentLocation != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildMetricsCard("Steps",
                                "${trackerProvider.stepCount}", "small"),
                            buildMetricsCard(
                                "Time", trackerProvider.displayTime, "small"),
                            buildMetricsCard(
                                "Distance covered",
                                trackerProvider.distance.toStringAsFixed(2),
                                "small"),
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
                                  "${trackerProvider.targetSteps}",
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
                            if (trackerProvider.progress != null)
                              Text(
                                "${(trackerProvider.progress * 100).clamp(0, 100).toStringAsFixed(1)}%",
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
                          value: trackerProvider.progress,
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
    final trackerProvider = Provider.of<TrackerProvider>(context);

    return ActionButtons(
      buttonState: buttonState,
      onStart: () {
        if (trackerProvider.targetSteps != 0) {
          trackerProvider.startTimer();
          trackerProvider.startRealTimeTracking();
          trackerProvider.monitorSpeed(); //  speed monitoring
          trackerProvider.isStarted = true;
          setState(() {
            buttonState = 'pause';
          });
        }
      },
      onPause: () {
        trackerProvider.pauseTracking();
        setState(() {
          buttonState = 'resume';
        });
      },
      onResume: () {
        trackerProvider.resumeTracking();
        setState(() {
          buttonState = 'pause';
        });
      },
      onFinish: () {
        trackerProvider.pauseTracking();
        removeOverlay();
        setState(() {
          isFinish = true;
        });
        trackerProvider.disposeService();
      },
      onSwitchMap: () {
        setState(() {
          showMap = !showMap;
        });
      },
      progress: trackerProvider.progress,
      capturedImages: capturedImages,
      steps: trackerProvider.stepCount,
      distance: trackerProvider.distance,
      timeDuration: trackerProvider.timeDuration,
    );
  }

  void selectRouteConfirmation(
      BuildContext context, Function(bool) onRouteSelected) {
    overlayEntryRoute = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 22,
        left: 5,
        right: 5,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.directions_outlined,
                  color: Color(0xFF5F6368),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Would you like to enable route suggestions?",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF373737),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                ),
                const SizedBox(width: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        onRouteSelected(true);
                        removeOverlay();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF9C9C9C),
                          width: 1,
                        ),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Yes",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        onRouteSelected(false);
                        removeOverlay();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(
                          color: Color(0xFF9C9C9C),
                          width: 1,
                        ),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(60, 30),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "No",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntryRoute!);
  }

  void removeOverlay() {
    overlayEntryRoute?.remove();
    overlayEntryRoute = null;
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
