//lib\widgets\octagon_painter.dart

import 'package:flutter/material.dart';
import 'dart:math';

class OctagonPainter extends CustomPainter {
  final Color fillColor;
  OctagonPainter(this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    final double R = size.width / 2;
    final Offset c = Offset(size.width / 2, size.height / 2);

    final Path octagon = Path();
    for (int i = 0; i < 8; i++) {
      double angle = (pi / 8) + (i * 2 * pi / 8);
      double x = c.dx + R * cos(angle);
      double y = c.dy - R * sin(angle);
      if (i == 0) {
        octagon.moveTo(x, y);
      } else {
        octagon.lineTo(x, y);
      }
    }
    octagon.close();

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(octagon, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
