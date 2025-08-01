import 'package:flutter/material.dart';

class DogPieceWidget extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelected;

  const DogPieceWidget({
    super.key,
    required this.color,
    required this.size,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.white,
          width: isSelected ? 4.0 : 2.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  // Bruker withAlpha for å sette opasiteten til 50%
                  color: Colors.orange.withAlpha(127),
                  spreadRadius: 3,
                  blurRadius: 5,
                ),
              ]
            : [
                BoxShadow(
                  // Bruker withAlpha for å sette opasiteten til 20%
                  color: Colors.black.withAlpha(51),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
      ),
    );
  }
}
