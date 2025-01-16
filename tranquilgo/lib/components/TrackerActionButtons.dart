import 'package:flutter/material.dart';
import 'package:my_app/screens/Walking/ActivityForm.dart';

class ActionButtons extends StatelessWidget {
  final String buttonState;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onFinish;
  final VoidCallback onSwitchMap;
  final double progress;

  const ActionButtons({
    required this.buttonState,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onFinish,
    required this.onSwitchMap,
    required this.progress,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (buttonState) {
      case 'start':
        return _buildStartButton();
      case 'pause':
        return _buildPauseButton();
      case 'resume':
        return _buildResumeButton(context);
      default:
        return Container();
    }
  }

  Widget _buildStartButton() {
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
        onPressed: onStart,
      ),
    );
  }

  Widget _buildPauseButton() {
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
            onPressed: onPause,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildSwitchButton(),
        ),
      ],
    );
  }

  Widget _buildResumeButton(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 220,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                icon: Icons.play_arrow_rounded,
                size: 35,
                color: const Color(0xFF636363),
                backgroundColor: const Color(0xFFF8F8F8),
                onPressed: onResume,
              ),
              const SizedBox(width: 20),
              _buildIconButton(
                icon: Icons.check_rounded,
                size: 30,
                color: Colors.white,
                backgroundColor: const Color(0xFF71B9B0),
                onPressed: () {
                  if (progress == 0) {
                    onFinish();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ActivityForm(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: _buildSwitchButton(),
        ),
      ],
    );
  }

  Widget _buildIconButton({
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

  Widget _buildSwitchButton() {
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
            onTap: onSwitchMap,
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
