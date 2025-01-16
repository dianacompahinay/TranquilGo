import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          child: CustomPaint(
            size: const Size(102, 90),
            painter: GradientProgressPainter(progress),
          ),
        ),
        ClipPath(
          clipper: OvalClipper(),
          child: Container(
            width: 82,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                '${(progress * 100).floor()}%',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF454459),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GradientProgressPainter extends CustomPainter {
  final double progress;

  GradientProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    Paint foregroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF8CDBCE),
          Color(0xFF75C2B6),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.12) // shadow color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    // flip the canvas horizontally
    canvas.save();
    canvas.translate(size.width, 0);
    canvas.scale(-1, 1);

    // define the elliptical bounds
    Rect rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    Rect rect1 = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width - 6,
      height: size.height - 6,
    );

    // draw the background ellipse
    canvas.drawArc(
      rect1,
      -3.141592653589793 / 2,
      2 * 3.141592653589793,
      false,
      backgroundPaint,
    );

    // draw the shadow arc
    Offset shadowOffset = const Offset(0, -5); // Offset for the shadow
    canvas.translate(shadowOffset.dx, shadowOffset.dy);
    double sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(
      rect,
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      shadowPaint,
    );
    canvas.translate(-shadowOffset.dx, -shadowOffset.dy);

    // draw the foreground (progress) arc
    canvas.drawArc(
      rect,
      -3.141592653589793 / 2,
      sweepAngle,
      false,
      foregroundPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// draw an oval shape
class OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
