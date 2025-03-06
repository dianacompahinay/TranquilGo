import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/screens/Walking/ActivityForm.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/providers/TrackerProvider.dart';
import 'package:my_app/components/TrackerConfirmationDialog.dart';

class ActionButtons extends StatefulWidget {
  final String buttonState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onSwitchMap;
  final double progress;
  final List<XFile>? capturedImages;
  final int steps;
  final double distance;
  final int timeDuration;

  const ActionButtons({
    required this.buttonState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onSwitchMap,
    required this.progress,
    required this.capturedImages,
    required this.steps,
    required this.distance,
    required this.timeDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  late String buttonState = widget.buttonState;

  Timestamp? startTime;

  @override
  void initState() {
    super.initState();
    buttonState = widget.buttonState;
  }

  void handleStart() {
    setState(() {
      buttonState = 'pause';
      startTime = Timestamp.now();
    });
    widget.onStart();
  }

  void handlePause() {
    setState(() {
      buttonState = 'resume';
    });
    widget.onPause();
  }

  void handleResume() {
    setState(() {
      buttonState = 'pause';
    });
    widget.onResume();
  }

  void handleFinish() {
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    switch (buttonState) {
      case 'start':
        return buildStartButton();
      case 'pause':
        return buildPauseButton();
      case 'resume':
        return buildResumeButton(context);
      default:
        return Container();
    }
  }

  Widget buildStartButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF55AC9F),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.play_arrow_rounded,
          size: 35,
          color: Colors.white,
        ),
        onPressed: handleStart,
      ),
    );
  }

  Widget buildPauseButton() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF89CBC4),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.square_rounded,
              color: Colors.white,
            ),
            onPressed: handlePause,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: buildSwitchButton(),
        ),
      ],
    );
  }

  Widget buildResumeButton(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final trackerProvider =
        Provider.of<TrackerProvider>(context, listen: false);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildIconButton(
                icon: Icons.play_arrow_rounded,
                size: 35,
                color: const Color(0xFF636363),
                backgroundColor: const Color(0xFFF8F8F8),
                onPressed: handleResume,
              ),
              const SizedBox(width: 20),
              buildIconButton(
                icon: Icons.check_rounded,
                size: 30,
                color: Colors.white,
                backgroundColor: const Color(0xFF71B9B0),
                onPressed: () {
                  handleFinish();
                  if (widget.progress == 0) {
                    ConfirmationDialog.show(
                      context: context,
                      type: "zero_steps",
                      onCancel: () {},
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ActivityForm(
                          startTime: startTime!,
                          endTime: Timestamp.now(),
                          duration: widget.timeDuration,
                          steps: widget.steps,
                          distance: widget.distance,
                          capturedImages: widget.capturedImages ?? [],
                        ),
                      ),
                    );
                    trackerProvider.resetValues(userId);
                    trackerProvider.disposeService();
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: buildSwitchButton(),
        ),
      ],
    );
  }

  Widget buildIconButton({
    required IconData icon,
    required double size,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget buildSwitchButton() {
    return Container(
      width: 33,
      height: 33,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onSwitchMap,
            splashColor: const Color(0xFF71B9B0).withOpacity(0.75),
            borderRadius: BorderRadius.circular(25),
            child: Ink(
              child: Padding(
                padding: const EdgeInsets.all(6.5),
                child: Image.asset(
                  'assets/icons/swap.png',
                  width: 33,
                  height: 33,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
