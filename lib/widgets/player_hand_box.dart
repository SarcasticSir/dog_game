import 'package:flutter/material.dart';

class PlayerHandBox extends StatelessWidget {
  final int player;
  final double width;
  final bool isMe;
  const PlayerHandBox({super.key, required this.player, required this.width, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final Map<int, Color> playerColor = {
      1: Colors.red,
      2: Colors.blue,
      3: Colors.yellow,
      4: Colors.purple,
    };
    return Container(
      width: width,
      height: width * 0.60,
      decoration: BoxDecoration(
        color: playerColor[player]!.withAlpha((isMe ? 64 : 46)), // ~0.25 og 0.18
        border: Border.all(color: playerColor[player]!, width: isMe ? 3 : 2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: playerColor[player]!.withAlpha(61), // ~0.24
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(
          "Player $player",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: playerColor[player],
            fontSize: width * 0.23, // funker, men scalert uansett!
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
