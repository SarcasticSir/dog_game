// Nyeste DOG-brett med riktig roterende perspektiv og håndbokser
import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const DogGameApp());

class DogGameApp extends StatelessWidget {
  const DogGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green,
        body: SafeArea(child: DogBoard()),
      ),
    );
  }
}

class Field {
  final Offset relPos;
  final String type; // 'normal', 'immunity', 'start', 'goal'
  final int? startNumber;
  final int? player;
  final int? goalNumber;
  Field(this.relPos, this.type, {this.startNumber, this.player, this.goalNumber});
}

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  int currentPos = 0;

  /// Endre denne for å se hvordan brettet tilpasses!
  final int myPlayerNumber = 1;

  final Map<int, Color> playerStartColor = {
    1: Colors.red,
    2: Colors.blue,
    3: Colors.yellow,
    4: Colors.purple,
  };

  double getBoardRotation(int player) {
    switch (player) {
      case 1:
        return 0.0;
      case 2:
        return pi / 2;
      case 3:
        return pi;
      case 4:
        return 3 * pi / 2;
      default:
        return 0.0;
    }
  }

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
      Field(Offset(0.04, 0.08), 'start', startNumber: 1, player: 1),
      Field(Offset(0.04, 0.14), 'start', startNumber: 2, player: 1),
      Field(Offset(0.04, 0.20), 'start', startNumber: 3, player: 1),
      Field(Offset(0.04, 0.26), 'start', startNumber: 4, player: 1),
      Field(Offset(0.92, 0.04), 'start', startNumber: 1, player: 2),
      Field(Offset(0.86, 0.04), 'start', startNumber: 2, player: 2),
      Field(Offset(0.80, 0.04), 'start', startNumber: 3, player: 2),
      Field(Offset(0.74, 0.04), 'start', startNumber: 4, player: 2),
      Field(Offset(0.96, 0.92), 'start', startNumber: 1, player: 3),
      Field(Offset(0.96, 0.86), 'start', startNumber: 2, player: 3),
      Field(Offset(0.96, 0.80), 'start', startNumber: 3, player: 3),
      Field(Offset(0.96, 0.74), 'start', startNumber: 4, player: 3),
      Field(Offset(0.08, 0.96), 'start', startNumber: 1, player: 4),
      Field(Offset(0.14, 0.96), 'start', startNumber: 2, player: 4),
      Field(Offset(0.20, 0.96), 'start', startNumber: 3, player: 4),
      Field(Offset(0.26, 0.96), 'start', startNumber: 4, player: 4),
    ];
    final List<Field> goalFields = [
      Field(Offset(0.17, 0.17), 'goal', goalNumber: 1, player: 1),
      Field(Offset(0.21, 0.21), 'goal', goalNumber: 2, player: 1),
      Field(Offset(0.25, 0.25), 'goal', goalNumber: 3, player: 1),
      Field(Offset(0.29, 0.29), 'goal', goalNumber: 4, player: 1),
      Field(Offset(0.83, 0.17), 'goal', goalNumber: 1, player: 2),
      Field(Offset(0.79, 0.21), 'goal', goalNumber: 2, player: 2),
      Field(Offset(0.75, 0.25), 'goal', goalNumber: 3, player: 2),
      Field(Offset(0.71, 0.29), 'goal', goalNumber: 4, player: 2),
      Field(Offset(0.83, 0.83), 'goal', goalNumber: 1, player: 3),
      Field(Offset(0.79, 0.79), 'goal', goalNumber: 2, player: 3),
      Field(Offset(0.75, 0.75), 'goal', goalNumber: 3, player: 3),
      Field(Offset(0.71, 0.71), 'goal', goalNumber: 4, player: 3),
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
        final double boxHeight = boxWidth * 0.6;
        final double offset = boardSide * 0.07;

        // Hvilke spillere skal vises hvor? (rotasjon for håndboksene)
        List<int> boxOrder = [
          myPlayerNumber, // BUNN (meg)
          ((myPlayerNumber) % 4) + 1, // HØYRE
          ((myPlayerNumber + 1) % 4) + 1, // TOPP
          ((myPlayerNumber + 2) % 4) + 1, // VENSTRE
        ];

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
                        child: Text(
                          '${f.goalNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: size * 0.6,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                          ),
                        ),
                      );
                    } else if (f.type == 'start') {
                      label = Transform.rotate(
                        angle: -getBoardRotation(myPlayerNumber),
                        child: Text(
                          '${f.startNumber}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: size * 0.6,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
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
                  )
                ],
              ),
            ),
            // Håndbokser: Legg dem på innsiden av brettet – nær senteret, alltid samme avstand
              // BUNN (meg)
              Positioned(
                left: boardOrigin.dx + (boardSide - boxWidth) / 2,
                top: boardOrigin.dy + boardSide * 0.845,
                child: PlayerHandBox(player: boxOrder[0], width: boxWidth, isMe: true),
              ),
              // HØYRE (90 grader)
              Positioned(
                left: boardOrigin.dx + boardSide * 0.8,
                top: boardOrigin.dy + (boardSide - boxWidth) / 1.8,
                child: Transform.rotate(
                  angle: pi / 2,
                  child: PlayerHandBox(player: boxOrder[1], width: boxWidth),
                ),
              ),
              // TOPP (180 grader)
              Positioned(
                left: boardOrigin.dx + (boardSide - boxWidth) / 2,
                top: boardOrigin.dy - boxHeight * -0.2,
                child: Transform.rotate(
                  angle: pi,
                  child: PlayerHandBox(player: boxOrder[2], width: boxWidth),
                ),
              ),
              // VENSTRE (-90 grader)
              Positioned(
                left: boardOrigin.dx - boxHeight * 0.2,
                top: boardOrigin.dy + (boardSide - boxWidth) / 1.8,
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: PlayerHandBox(player: boxOrder[3], width: boxWidth),
                ),
              ),


            // KNAPP for å flytte brikke (for testing)
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

// Oktagontegner (startfelt)
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

// DiamondPainter for mål (goal)
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

// Spillernes hand-bokser
class PlayerHandBox extends StatelessWidget {
  final int player;
  final double width;
  final bool isMe;
  const PlayerHandBox({
    super.key,
    required this.player,
    required this.width,
    this.isMe = false,
  });

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
        color: playerColor[player]!.withOpacity(isMe ? 0.25 : 0.18),
        border: Border.all(color: playerColor[player]!, width: isMe ? 3 : 2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: isMe
            ? [
                BoxShadow(
                  color: playerColor[player]!.withOpacity(0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      alignment: Alignment.center,
      child: Text(
        isMe ? "You" : "$player",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: playerColor[player],
          fontSize: width * 0.23,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

// Rektangel midt på brettet med "DOG"
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
        border: Border.all(color: Colors.white, width: 4),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 12,
            offset: const Offset(2, 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        "DOG",
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontFamily: 'Arial Black',
          fontSize: 56,
          color: Colors.white,
          letterSpacing: 7,
          shadows: [Shadow(blurRadius: 3, color: Colors.deepOrange, offset: Offset(0, 2))],
        ),
      ),
    );
  }
}

            
