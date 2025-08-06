// lib\widgets\dog_piece_widget.dart


import 'package:flutter/material.dart';

class DogPieceWidget extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelected;
  final bool isInPlay;
  final Color outlineColor;

  const DogPieceWidget({
    super.key,
    required this.color,
    required this.size,
    required this.isSelected,
    required this.isInPlay,
    required this.outlineColor,
  });

  @override
  Widget build(BuildContext context) {
    double outlineWidth = isSelected ? size * 0.13 : size * 0.09;

    return Opacity(
      opacity: isInPlay ? 1.0 : 0.45,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: outlineColor,
            width: outlineWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: size * 0.18,
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Center(
          child: isSelected
              ? Container(
                  width: size * 0.48,
                  height: size * 0.48,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(35),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
