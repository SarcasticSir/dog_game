// lib\widgets\center_box.dart


import 'package:flutter/material.dart';

class CenterBox extends StatelessWidget {
  final double width;
  const CenterBox({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1,
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border.all(color: const Color.fromARGB(255, 155, 9, 9), width: 4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(61),
            blurRadius: 12,
            offset: const Offset(2, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          "DOG",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Arial Black',
            fontSize: 56,
            color: Colors.white,
            letterSpacing: 7,
            shadows: [Shadow(blurRadius: 3, color: Colors.deepOrange, offset: Offset(0, 2))],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
