import 'dart:math';
import 'package:flutter/material.dart';

import '../models/field.dart';
import '../utils/board_rotation.dart';
import 'octagon_painter.dart';
import 'diamond_painter.dart';
import 'player_hand_box.dart';
import 'center_box.dart';

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  int currentPos = 0;

  /// Hvilken spiller vises NEDERST (0=1, 1=2, ...)
  final int myPlayerNumber = 3;

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
  }

  List<Field> _manualFields() {
    final coords = [
      Offset(0.10, 0.10), Offset(0.15, 0.10), Offset(0.20, 0.10), Offset(0.25, 0.15),
      Offset(0.30, 0.20), Offset(0.35, 0.25), Offset(0.40, 0.30), Offset(0.45, 0.35),
      Offset(0.50, 0.35), Offset(0.55, 0.35), Offset(0.60, 0.30), Offset(0.65, 0.25),
      Offset(0.70, 0.20), Offset(0.75, 0.15), Offset(0.80, 0.10), Offset(0.85, 0.10),
      Offset(0.90, 0.10), Offset(0.90, 0.15), Offset(0.90, 0.20), Offset(0.85, 0.25),
      Offset(0.80, 0.30), Offset(0.75, 0.35), Offset(0.70, 0.40), Offset(0.65, 0.45),
      Offset(0.65, 0.50), Offset(0.65, 0.55), Offset(0.70, 0.60), Offset(0.75, 0.65),
      Offset(0.80, 0.70), Offset(0.85, 0.75), Offset(0.90, 0.80), Offset(0.90, 0.85),
      Offset(0.90, 0.90), Offset(0.85, 0.90), Offset(0.80, 0.90), Offset(0.75, 0.85),
      Offset(0.70, 0.80), Offset(0.65, 0.75), Offset(0.60, 0.70), Offset(0.55, 0.65),
      Offset(0.50, 0.65), Offset(0.45, 0.65), Offset(0.40, 0.70), Offset(0.35, 0.75),
      Offset(0.30, 0.80), Offset(0.25, 0.85), Offset(0.20, 0.90), Offset(0.15, 0.90),
      Offset(0.10, 0.90), Offset(0.10, 0.85), Offset(0.10, 0.80), Offset(0.15, 0.75),
      Offset(0.20, 0.70), Offset(0.25, 0.65), Offset(0.30, 0.60), Offset(0.35, 0.55),
      Offset(0.35, 0.50), Offset(0.35, 0.45), Offset(0.30, 0.40), Offset(0.25, 0.35),
      Offset(0.20, 0.30), Offset(0.15, 0.25), Offset(0.10, 0.20), Offset(0.10, 0.15),
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
          ((i == 0) || (i == 16) || (i == 32) || (i == 48)) ? 'immunity' : 'normal',
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
        final double boardSide = constraints.biggest.shortestSide * 0.85;
        final Offset boardOrigin = Offset(
          (constraints.maxWidth - boardSide) / 2,
          (constraints.maxHeight - boardSide) / 2,
        );
        double baseFieldSize = boardSide * 0.05;
        double immunityMultiplier = 1.2;
        double startMultiplier = 1.13;
        double pieceSize = baseFieldSize * 0.8;
        final double boxWidth = boardSide * 0.23;
        final double boxHeight = boxWidth * 0.60;
        //final double offset = boardSide * 0.07; fjerner denne da den ikke trengs.

        // Hvilke spillere skal vises hvor? (rotasjon for håndboksene)
List<int> boxOrder = [
  myPlayerNumber, // BUNN (deg)
  (myPlayerNumber % 4) + 1, // VENSTRE (med klokka)
  ((myPlayerNumber + 1) % 4) + 1, // TOPP
  ((myPlayerNumber + 2) % 4) + 1, // HØYRE
];

        // Håndboksene skal alltid være i samme posisjon ift. brettet

        return Stack(
          children: [
            // Rotér hele brettet ift. meg
            Transform.rotate(
              angle: getBoardRotation(myPlayerNumber),
              child: Stack(
                children: [
                  // Brettet
                  Positioned(
                    left: boardOrigin.dx,
                    top: boardOrigin.dy,
                    child: Container(
                      width: boardSide,
                      height: boardSide,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 4),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                  ),
                  // FELTER
                  ...fields.asMap().entries.map((entry) {
                    final f = entry.value;
                    final pos = Offset(
                      boardOrigin.dx + f.relPos.dx * boardSide,
                      boardOrigin.dy + f.relPos.dy * boardSide,
                    );
                    double size = baseFieldSize;
                    if (f.type == 'immunity') size *= immunityMultiplier;
                    if (f.type == 'start') size *= startMultiplier;

                    Color color;
                    if (f.type == 'immunity' || f.type == 'goal' || f.type == 'start') {
                      color = playerStartColor[f.player] ?? Colors.green;
                    } else {
                      color = Colors.black;
                    }

                    // Tekst skal ALLTID stå rett vei ift. spilleren
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
                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
                              shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
                                border: Border.all(color: Colors.white, width: size * 0.14),
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
                  // BRIKKE (test)
                  Builder(builder: (context) {
                    final pos = Offset(
                      boardOrigin.dx + fields[currentPos].relPos.dx * boardSide,
                      boardOrigin.dy + fields[currentPos].relPos.dy * boardSide,
                    );
                    return Positioned(
                      left: pos.dx - pieceSize / 2,
                      top: pos.dy - pieceSize / 2,
                      child: Container(
                        width: pieceSize,
                        height: pieceSize,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 3, 224, 195),
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(2, 3),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                  // Brettets midt-boks
                  Positioned(
                    left: boardOrigin.dx + boardSide * 0.375,
                    top: boardOrigin.dy + boardSide * 0.375,
                    child: Transform.rotate(
                      angle: -getBoardRotation(myPlayerNumber),
                      child: CenterBox(width: boardSide * 0.25),
                    ),
                  ),
                ],
              ),
            ),
            // Spillernes handbokser (alltid i viewport, ikke rotert)
// BUNN (meg)
Positioned(
  left: boardOrigin.dx + (boardSide - boxWidth) / 2,
  top: boardOrigin.dy + boardSide * 0.845,
  child: PlayerHandBox(player: boxOrder[0], width: boxWidth, isMe: true),
),
// VENSTRE (-90 grader)
Positioned(
  left: boardOrigin.dx - boxHeight * 0.2,
  top: boardOrigin.dy + (boardSide - boxWidth) / 1.8,
  child: Transform.rotate(
    angle: -pi / 2,
    child: PlayerHandBox(player: boxOrder[1], width: boxWidth),
  ),
),
// TOPP (180 grader)
Positioned(
  left: boardOrigin.dx + (boardSide - boxWidth) / 2,
  top: boardOrigin.dy - boxHeight * -0.15,
  child: Transform.rotate(
    angle: pi * 2,
    child: PlayerHandBox(player: boxOrder[2], width: boxWidth),
  ),
),
// HØYRE (90 grader)
Positioned(
  left: boardOrigin.dx + boardSide * 0.8,
  top: boardOrigin.dy + (boardSide - boxWidth) / 1.8,
  child: Transform.rotate(
    angle: pi / 2,
    child: PlayerHandBox(player: boxOrder[3], width: boxWidth),
  ),
),
              
              
                          // KNAPP for å flytte brikke (test)
            Positioned(
              left: 30,
              bottom: 30,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentPos = (currentPos + 1) % 64;
                  });
                },
                child: const Text("Flytt brikke"),
              ),
            ),
          ],
        );
      },
    );
  }
}
