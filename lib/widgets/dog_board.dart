import 'dart:math';
import 'package:flutter/material.dart';

import '../models/field.dart';
import '../game_manager.dart';
import '../utils/board_rotation.dart';
import 'octagon_painter.dart';
import 'diamond_painter.dart';
import 'player_hand_box.dart';
import 'center_box.dart';
import 'dog_piece_widget.dart';
import '../dog_card.dart';

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  late GameManager gameManager;

  DogCard? selectedCard;
  DogCard? hoveredCard;

  /// Hvilken spiller vises NEDERST (1=1, 2=2, ...)
  final int myPlayerNumber = 2;

  final Map<int, Color> playerStartColor = {
    1: Colors.red,
    2: Colors.blue,
    3: Colors.yellow,
    4: Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    fields = _manualFields();
    gameManager = GameManager(fields: fields);
  }

  List<Field> _manualFields() {
    final coords = [
      Offset(0.10, 0.10),
      Offset(0.15, 0.10),
      Offset(0.20, 0.10),
      Offset(0.25, 0.15),
      Offset(0.30, 0.20),
      Offset(0.35, 0.25),
      Offset(0.40, 0.30),
      Offset(0.45, 0.35),
      Offset(0.50, 0.35),
      Offset(0.55, 0.35),
      Offset(0.60, 0.30),
      Offset(0.65, 0.25),
      Offset(0.70, 0.20),
      Offset(0.75, 0.15),
      Offset(0.80, 0.10),
      Offset(0.85, 0.10),
      Offset(0.90, 0.10),
      Offset(0.90, 0.15),
      Offset(0.90, 0.20),
      Offset(0.85, 0.25),
      Offset(0.80, 0.30),
      Offset(0.75, 0.35),
      Offset(0.70, 0.40),
      Offset(0.65, 0.45),
      Offset(0.65, 0.50),
      Offset(0.65, 0.55),
      Offset(0.70, 0.60),
      Offset(0.75, 0.65),
      Offset(0.80, 0.70),
      Offset(0.85, 0.75),
      Offset(0.90, 0.80),
      Offset(0.90, 0.85),
      Offset(0.90, 0.90),
      Offset(0.85, 0.90),
      Offset(0.80, 0.90),
      Offset(0.75, 0.85),
      Offset(0.70, 0.80),
      Offset(0.65, 0.75),
      Offset(0.60, 0.70),
      Offset(0.55, 0.65),
      Offset(0.50, 0.65),
      Offset(0.45, 0.65),
      Offset(0.40, 0.70),
      Offset(0.35, 0.75),
      Offset(0.30, 0.80),
      Offset(0.25, 0.85),
      Offset(0.20, 0.90),
      Offset(0.15, 0.90),
      Offset(0.10, 0.90),
      Offset(0.10, 0.85),
      Offset(0.10, 0.80),
      Offset(0.15, 0.75),
      Offset(0.20, 0.70),
      Offset(0.25, 0.65),
      Offset(0.30, 0.60),
      Offset(0.35, 0.55),
      Offset(0.35, 0.50),
      Offset(0.35, 0.45),
      Offset(0.30, 0.40),
      Offset(0.25, 0.35),
      Offset(0.20, 0.30),
      Offset(0.15, 0.25),
      Offset(0.10, 0.20),
      Offset(0.10, 0.15),
    ];

    final List<Field> startFields = [
      // ØVERST VENSTRE (spiller 1)
      Field(Offset(0.04, 0.08), 'start', startNumber: 1, player: 1),
      Field(Offset(0.04, 0.14), 'start', startNumber: 2, player: 1),
      Field(Offset(0.04, 0.20), 'start', startNumber: 3, player: 1),
      Field(Offset(0.04, 0.26), 'start', startNumber: 4, player: 1),
      // ØVERST HØYRE (spiller 2)
      Field(Offset(0.92, 0.04), 'start', startNumber: 1, player: 2),
      Field(Offset(0.86, 0.04), 'start', startNumber: 2, player: 2),
      Field(Offset(0.80, 0.04), 'start', startNumber: 3, player: 2),
      Field(Offset(0.74, 0.04), 'start', startNumber: 4, player: 2),
      // NEDERST HØYRE (spiller 3)
      Field(Offset(0.96, 0.92), 'start', startNumber: 1, player: 3),
      Field(Offset(0.96, 0.86), 'start', startNumber: 2, player: 3),
      Field(Offset(0.96, 0.80), 'start', startNumber: 3, player: 3),
      Field(Offset(0.96, 0.74), 'start', startNumber: 4, player: 3),
      // NEDERST VENSTRE (spiller 4)
      Field(Offset(0.08, 0.96), 'start', startNumber: 1, player: 4),
      Field(Offset(0.14, 0.96), 'start', startNumber: 2, player: 4),
      Field(Offset(0.20, 0.96), 'start', startNumber: 3, player: 4),
      Field(Offset(0.26, 0.96), 'start', startNumber: 4, player: 4),
    ];

    final List<Field> goalFields = [
      // Spiller 1
      Field(Offset(0.17, 0.17), 'goal', goalNumber: 1, player: 1),
      Field(Offset(0.21, 0.21), 'goal', goalNumber: 2, player: 1),
      Field(Offset(0.25, 0.25), 'goal', goalNumber: 3, player: 1),
      Field(Offset(0.29, 0.29), 'goal', goalNumber: 4, player: 1),
      // Spiller 2
      Field(Offset(0.83, 0.17), 'goal', goalNumber: 1, player: 2),
      Field(Offset(0.79, 0.21), 'goal', goalNumber: 2, player: 2),
      Field(Offset(0.75, 0.25), 'goal', goalNumber: 3, player: 2),
      Field(Offset(0.71, 0.29), 'goal', goalNumber: 4, player: 2),
      // Spiller 3
      Field(Offset(0.83, 0.83), 'goal', goalNumber: 1, player: 3),
      Field(Offset(0.79, 0.79), 'goal', goalNumber: 2, player: 3),
      Field(Offset(0.75, 0.75), 'goal', goalNumber: 3, player: 3),
      Field(Offset(0.71, 0.71), 'goal', goalNumber: 4, player: 3),
      // Spiller 4
      Field(Offset(0.17, 0.83), 'goal', goalNumber: 1, player: 4),
      Field(Offset(0.21, 0.79), 'goal', goalNumber: 2, player: 4),
      Field(Offset(0.25, 0.75), 'goal', goalNumber: 3, player: 4),
      Field(Offset(0.29, 0.71), 'goal', goalNumber: 4, player: 4),
    ];

    return [
      for (int i = 0; i < coords.length; i++)
        Field(
          coords[i],
          ((i == 0) || (i == 16) || (i == 32) || (i == 48))
              ? 'immunity'
              : 'normal',
          player: (i == 0)
              ? 1
              : (i == 16)
              ? 2
              : (i == 32)
              ? 3
              : (i == 48)
              ? 4
              : null,
        ),
      ...startFields,
      ...goalFields,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= constraints.maxHeight * 1.3) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.screen_rotation,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Vennligst roter enheten din for å spille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final double boardSide = constraints.biggest.shortestSide * 0.85;
        double baseFieldSize = boardSide * 0.05;
        double immunityMultiplier = 1.2;
        double startMultiplier = 1.13;
        double pieceSize = baseFieldSize * 0.8;
        final double boxWidth = boardSide * 0.23;
        final double boxHeight = boxWidth * 0.60;
        final double cardWidth = boardSide * 0.12;
        final double cardHeight = cardWidth * 1.4;
        final double handCardSpacing = cardWidth * 0.05;

        List<int> boxOrder = [
          myPlayerNumber,
          (myPlayerNumber % 4) + 1,
          ((myPlayerNumber + 1) % 4) + 1,
          ((myPlayerNumber + 2) % 4) + 1,
        ];
        
        // Får spillerens farge og definerer hover/selected farger
        final Color playerColor = playerStartColor[myPlayerNumber]!;
        final Color hoverColor = playerColor.withAlpha((255 * 0.2).round());

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Venstre sidepanel for kort
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // KORTBUNKE OG TELLER
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: cardWidth * 1.2,
                          height: cardHeight * 1.2,
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Stack(
                            children: [
                              for (int i = 2; i >= 0; i--)
                                Positioned(
                                  left: i.toDouble() * cardWidth * 0.05,
                                  top: i.toDouble() * cardHeight * 0.05,
                                  child: Container(
                                    width: cardWidth,
                                    height: cardHeight,
                                    decoration: BoxDecoration(
                                      color: i == 0
                                          ? Colors.white
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 7,
                                          offset: Offset(2, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              Positioned(
                                left: cardWidth * 0.05,
                                top: cardHeight * 0.1,
                                child: SizedBox(
                                  width: cardWidth * 0.9,
                                  height: cardHeight * 0.9,
                                  child: Center(
                                    child: Icon(
                                      Icons.style,
                                      size: cardWidth * 0.8,
                                      color: Colors.blueGrey[300],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: cardWidth,
                          height: cardHeight * 0.4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 3),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${gameManager.deck.length} kort igjen',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: cardWidth * 0.15,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // HÅNDKORTENE DINE
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (row) {
                        int startIdx = row * 2;
                        final hand = gameManager.playerHands[myPlayerNumber - 1];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: handCardSpacing),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (col) {
                              int cardIdx = startIdx + col;
                              if (cardIdx >= hand.length) {
                                return SizedBox(
                                  width: cardWidth + handCardSpacing,
                                  height: cardHeight + handCardSpacing,
                                );
                              }
                              final card = hand[cardIdx];
                              final isSelected = card == selectedCard;
                              return MouseRegion(
                                cursor: SystemMouseCursors.click,
                                onEnter: (_) {
                                  setState(() {
                                    hoveredCard = card;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    if (hoveredCard == card) hoveredCard = null;
                                  });
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCard = card;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 100),
                                    width: cardWidth,    
                                    height: cardHeight,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: handCardSpacing,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.orange
                                          : hoveredCard == card
                                              ? hoverColor
                                              : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : hoveredCard == card
                                                ? playerColor
                                                : Colors.black26,
                                        width: isSelected
                                            ? 3
                                            : hoveredCard == card
                                                ? 2.3
                                                : 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: Colors.orange,
                                            blurRadius: 7,
                                            offset: const Offset(0, 2),
                                          ),
                                        if (hoveredCard == card && !isSelected)
                                          BoxShadow(
                                            color: playerColor.withAlpha((255 * 0.5).round()),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        card.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: cardWidth * 0.25,
                                          color: card.suit == Suit.hearts || card.suit == Suit.diamonds
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // Midten av Row: Spillbrettet og spillerboksene
              Stack(
                alignment: Alignment.center,
                children: [
                  // Rotert spillbrett
                  Transform.rotate(
                    angle: getBoardRotation(myPlayerNumber),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Brettet
                        Container(
                          width: boardSide,
                          height: boardSide,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        // FELTER
                        ...fields.asMap().entries.map((entry) {
                          final f = entry.value;
                          final pos = Offset(
                            f.relPos.dx * boardSide,
                            f.relPos.dy * boardSide,
                          );
                          double size = baseFieldSize;
                          if (f.type == 'immunity') size *= immunityMultiplier;
                          if (f.type == 'start') size *= startMultiplier;

                          Color color;
                          if (f.type == 'immunity' ||
                              f.type == 'goal' ||
                              f.type == 'start') {
                            color = playerStartColor[f.player] ?? Colors.green;
                          } else {
                            color = Colors.black;
                          }

                          Widget? label;
                          if (f.type == 'goal') {
                            label = Transform.rotate(
                              angle: -getBoardRotation(myPlayerNumber),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${f.goalNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: size * 0.6,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else if (f.type == 'start') {
                            label = Transform.rotate(
                              angle: -getBoardRotation(myPlayerNumber),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${f.startNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: size * 0.6,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return Positioned(
                            left: pos.dx - size / 2,
                            top: pos.dy - size / 2,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (f.type == 'start')
                                  CustomPaint(
                                    size: Size(size, size),
                                    painter: OctagonPainter(color),
                                  )
                                else
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: size * 0.14,
                                      ),
                                    ),
                                  ),
                                if (f.type == 'goal')
                                  CustomPaint(
                                    size: Size(size, size),
                                    painter: DiamondPainter(color),
                                  ),
                                if (label != null) label,
                              ],
                            ),
                          );
                        }),
                        // BRIKKER
                        ...gameManager.pieces.map((piece) {
                          final field = fields[piece.fieldIndex];
                          final pos = Offset(
                            field.relPos.dx * boardSide,
                            field.relPos.dy * boardSide,
                          );
                          Color color =
                              playerStartColor[piece.player] ?? Colors.black;
                          return Positioned(
                            left: pos.dx - pieceSize / 2,
                            top: pos.dy - pieceSize / 2,
                            child: DogPieceWidget(
                              color: color,
                              size: pieceSize,
                            ),
                          );
                        }),
                        // Brettets midt-boks
                        Transform.rotate(
                          angle: -getBoardRotation(myPlayerNumber),
                          child: CenterBox(width: boardSide * 0.25),
                        ),
                      ],
                    ),
                  ),

                  // Spillernes handbokser (plassert rundt brettet, men ikke rotert med det)
                  // BUNN (meg)
                  Positioned(
                    bottom: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: PlayerHandBox(
                      player: boxOrder[0],
                      width: boxWidth,
                      isMe: true,
                    ),
                  ),
                  // VENSTRE
                  Positioned(
                    left: -boxHeight * 0.2,
                    top: (boardSide - boxWidth) / 2 + (boxWidth * 0.2),
                    child: Transform.rotate(
                      angle: -pi / 2,
                      child: PlayerHandBox(
                        player: boxOrder[1],
                        width: boxWidth,
                      ),
                    ),
                  ),
                  // TOPP
                  Positioned(
                    top: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: Transform.rotate(
                      angle: pi * 2,
                      child: PlayerHandBox(
                        player: boxOrder[2],
                        width: boxWidth,
                      ),
                    ),
                  ),
                  // HØYRE
                  Positioned(
                    right: -boxHeight * 0.2,
                    top: (boardSide - boxWidth) / 2 + (boxWidth * 0.2),
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: PlayerHandBox(
                        player: boxOrder[3],
                        width: boxWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
