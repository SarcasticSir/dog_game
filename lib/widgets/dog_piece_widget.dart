import 'package:flutter/material.dart';

class DogPieceWidget extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelected;
  // Ny egenskap for å skille brikker som er i spill fra de i startområdet
  final bool isInPlay;

  const DogPieceWidget({
    super.key,
    required this.color,
    required this.size,
    this.isSelected = false,
    this.isInPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    // Definere kanten og skyggen basert på om brikken er i spill
    final double borderWidth = isInPlay ? size * 0.15 : size * 0.08;
    final double shadowBlurRadius = isInPlay ? 8 : 4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.white,
          width: isSelected ? size * 0.2 : borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            // Bruker withAlpha for å justere gjennomsiktigheten, i tråd med resten av koden
            color: isSelected ? Colors.orange.withAlpha((255 * 0.8).round()) : Colors.black26,
            blurRadius: isSelected ? 12 : shadowBlurRadius,
            offset: const Offset(2, 3),
          ),
        ],
      ),
    );
  }
}
