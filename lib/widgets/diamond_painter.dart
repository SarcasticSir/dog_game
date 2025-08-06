// lib\widgets\diamond_painter.dart


import 'package:flutter/material.dart';

class DiamondPainter extends CustomPainter {
  final Color fillColor;
  DiamondPainter(this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Path diamond = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(0, size.height / 2)
      ..close();
    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(diamond, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
