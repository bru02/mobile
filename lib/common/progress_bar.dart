import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({Key? key, required this.value, this.backgroundColor}) : super(key: key);

  final double value;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light ? Colors.black.withOpacity(0.1) : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(45.0),
          ),
          width: double.infinity,
          height: 8.0,
        ),

        // Slider
        Container(
          width: double.infinity,
          child: CustomPaint(
            painter: ProgressPainter(
              backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondary,
              height: 8.0,
              value: value.clamp(0, 1),
            ),
          ),
        )
      ],
    );
  }
}

class ProgressPainter extends CustomPainter {
  ProgressPainter({required this.height, required this.value, required this.backgroundColor});

  final double height;
  final double value;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width * value;

    if (width <= 0) return;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        Radius.circular(45.0),
      ),
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(ProgressPainter old) {
    return value != old.value || height != old.height || backgroundColor != old.backgroundColor;
  }
}