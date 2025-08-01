import 'package:flutter/material.dart';

import '../dog_card.dart';

class PlayerHandBox extends StatelessWidget {
  final int player;
  final double width;
  final bool isMe;
  final List<DogCard> hand;
  final bool isCurrentPlayer; // Ny parameter

  const PlayerHandBox({
    super.key,
    required this.player,
    required this.width,
    this.isMe = false,
    this.hand = const [], // Midlertidig
    this.isCurrentPlayer = false, // Standardverdi
  });

  @override
  Widget build(BuildContext context) {
    Color playerColor;
    switch (player) {
      case 1:
        playerColor = Colors.red;
        break;
      case 2:
        playerColor = Colors.blue;
        break;
      case 3:
        playerColor = Colors.yellow;
        break;
      case 4:
        playerColor = Colors.purple;
        break;
      default:
        playerColor = Colors.grey;
    }

    // `Container`-widgeten håndterer nå gløden basert på `isCurrentPlayer`.
    return Container(
      width: width,
      height: width * 0.6,
      decoration: BoxDecoration(
        color: isMe ? playerColor.withAlpha(200) : playerColor.withAlpha(100),
        border: Border.all(
          color: Colors.white, // Alle bokser har nå hvit kant
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isCurrentPlayer // Viser glød basert på isCurrentPlayer
            ? [
                BoxShadow(
                  color: playerColor.withAlpha(150),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          'Spiller $player',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 2,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
