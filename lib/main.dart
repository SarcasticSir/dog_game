import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const DogGameApp());

class DogGameApp extends StatelessWidget {
  const DogGameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.green, // <---- Endre bakgrunnsfarge her
        body: SafeArea(child: DogBoard()),
      ),
    );
  }
}

class Field {
  final Offset relPos;
  final String type; // 'normal', 'immunity', 'goal'
  final int? goalNumber;
  final int? player;
  Field(this.relPos, this.type, {this.goalNumber, this.player});
}

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  int currentPos = 0;

  // <--- FARGER per spiller. Du kan bytte disse!
  final Map<int, Color> playerGoalColor = {
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
      // ... (samme 64 koordinater som før, fjernet her for korthet)
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

    // --- BO/MÅL-FELT, 4 per spiller i hvert hjørne ---
    final List<Field> goalFields = [
      // ØVERST VENSTRE (spiller 1)
      Field(Offset(0.04, 0.08), 'goal', goalNumber: 1, player: 1),
      Field(Offset(0.04, 0.14), 'goal', goalNumber: 2, player: 1),
      Field(Offset(0.04, 0.20), 'goal', goalNumber: 3, player: 1),
      Field(Offset(0.04, 0.26), 'goal', goalNumber: 4, player: 1),
      // ØVERST HØYRE (spiller 2)
      Field(Offset(0.92, 0.04), 'goal', goalNumber: 1, player: 2),
      Field(Offset(0.86, 0.04), 'goal', goalNumber: 2, player: 2),
      Field(Offset(0.80, 0.04), 'goal', goalNumber: 3, player: 2),
      Field(Offset(0.74, 0.04), 'goal', goalNumber: 4, player: 2),
      // NEDERST HØYRE (spiller 3)
      Field(Offset(0.96, 0.92), 'goal', goalNumber: 1, player: 3),
      Field(Offset(0.96, 0.86), 'goal', goalNumber: 2, player: 3),
      Field(Offset(0.96, 0.80), 'goal', goalNumber: 3, player: 3),
      Field(Offset(0.96, 0.74), 'goal', goalNumber: 4, player: 3),
      // NEDERST VENSTRE (spiller 4)
      Field(Offset(0.08, 0.96), 'goal', goalNumber: 1, player: 4),
      Field(Offset(0.14, 0.96), 'goal', goalNumber: 2, player: 4),
      Field(Offset(0.20, 0.96), 'goal', goalNumber: 3, player: 4),
      Field(Offset(0.26, 0.96), 'goal', goalNumber: 4, player: 4),
    ];

    return [
      for (int i = 0; i < coords.length; i++)
        Field(
          coords[i],
          ((i == 0) || (i == 16) || (i == 32) || (i == 48)) ? 'immunity' : 'normal',
        ),
      ...goalFields,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boardSide = constraints.biggest.shortestSide * 0.9;
        final Offset boardOrigin = Offset(
          (constraints.maxWidth - boardSide) / 2,
          (constraints.maxHeight - boardSide) / 2,
        );

        // <--- JUSTER STØRRELSE på felter, bo-felt, immunfelt, brikke her!
        double baseFieldSize = boardSide * 0.05;
        double immunityMultiplier = 1.2;
        double goalMultiplier = 1.13;
        double pieceSize = baseFieldSize * 0.8;

        return Stack(
          children: [
            // Brettet (stor hvit firkant)
            Positioned(
              left: boardOrigin.dx,
              top: boardOrigin.dy,
              child: Container(
                width: boardSide,
                height: boardSide,
                decoration: BoxDecoration(
                  color: Colors.white, // <--- Endre farge på spillebrett her
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            // FELTER
            ...fields.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              final pos = Offset(
                boardOrigin.dx + f.relPos.dx * boardSide,
                boardOrigin.dy + f.relPos.dy * boardSide,
              );
              double size = baseFieldSize;
              if (f.type == 'immunity') size *= immunityMultiplier;
              if (f.type == 'goal') size *= goalMultiplier;

              Color color;
              if (f.type == 'immunity') {
                color = Colors.orange; // <--- Endre farge på immunfelt
              } else if (f.type == 'goal') {
                color = playerGoalColor[f.player] ?? Colors.green;
              } else {
                color = Colors.black; // <--- Endre farge på vanlige felter
              }

              // Bytt ut sirkelform med oktagon hvis det er mål-felt!
              return Positioned(
                left: pos.dx - size / 2,
                top: pos.dy - size / 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (f.type == 'goal')
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
                      Text(
                        '${f.goalNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: size * 0.6,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                  ],
                ),
              );
            }),
            // BRIKKE (bare én blå for testing)
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
                    color: Colors.blue, // <--- Endre farge på testbrikke
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
            // KNAPP for å flytte brikke
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

// === 🟩 CUSTOM PAINTER FOR OKTAGON (ÅTTEKANT) 🟩 ===
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
