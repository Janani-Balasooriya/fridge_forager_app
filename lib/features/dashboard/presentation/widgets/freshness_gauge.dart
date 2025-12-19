import 'dart:math';
import 'package:flutter/material.dart';

class FreshnessGauge extends StatelessWidget {
  final double score; // 0.0 to 1.0 (0% to 100%)

  const FreshnessGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: CustomPaint(
            painter: _GaugePainter(score),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(score * 100).toInt()}%",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const Text("Freshness", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  _GaugePainter(this.score);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 15.0;

    // Draw Background Arc (Grey)
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw from 135 degrees to 405 degrees (Open circle at bottom)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * pi / 4, // Start angle (135 deg)
      3 * pi / 2, // Sweep angle (270 deg)
      false,
      bgPaint,
    );

    // Draw Progress Arc (Gradient Color)
    // Calculate color: Red (0%) -> Yellow -> Green (100%)
    final color = Color.lerp(Colors.red, Colors.green, score)!;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3 * pi / 4, // Start at same point
      (3 * pi / 2) * score, // Sweep based on score
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}