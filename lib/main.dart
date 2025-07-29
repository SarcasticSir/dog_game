import 'package:flutter/material.dart';

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
  final Offset relPos; // 0.0 - 1.0 prosent-basert
  final String type; // 'normal', 'immunity'
  Field(this.relPos, this.type);
}

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  int currentPos = 0; // Hvor brikken står

  @override
  void initState() {
    super.initState();
    fields = _manualFields();
  }

  List<Field> _manualFields() {
    return List.generate(64, (i) {
      final coords = [
  // Topp (fra venstre mot høyre)
  Offset(0.10, 0.10),    // 1 (hjørne top venstre)
  Offset(0.15, 0.10),    // 2
  Offset(0.20, 0.10),    // 3
  Offset(0.25, 0.15),    // 4
  Offset(0.30, 0.20),    // 5
  Offset(0.35, 0.25),    // 6
  Offset(0.40, 0.30),    // 7
  Offset(0.45, 0.35),    // 8
  Offset(0.50, 0.35),    // 9 midten
  Offset(0.55, 0.35),    // 10
  Offset(0.60, 0.30),    // 11
  Offset(0.65, 0.25),    // 12
  Offset(0.70, 0.20),    // 13
  Offset(0.75, 0.15),    // 14
  Offset(0.80, 0.10),    // 15
  Offset(0.85, 0.10),    // 16

  // Høyre (topp til bunn)
  Offset(0.90, 0.10),    // 17 (hjørne top høyre)
  Offset(0.90, 0.15),    // 18
  Offset(0.90, 0.20),    // 19
  Offset(0.85, 0.25),    // 20
  Offset(0.80, 0.30),    // 21
  Offset(0.75, 0.35),    // 22
  Offset(0.70, 0.40),    // 23
  Offset(0.65, 0.45),    // 24
  Offset(0.65, 0.50),    // 25 midten
  Offset(0.65, 0.55),    // 26
  Offset(0.70, 0.60),    // 27
  Offset(0.75, 0.65),    // 28
  Offset(0.80, 0.70),    // 29
  Offset(0.85, 0.75),    // 30
  Offset(0.90, 0.80),    // 31
  Offset(0.90, 0.85),    // 32

  // Bunn (høyre mot venstre)
  Offset(0.90, 0.90),    // 33 (Hjørne bunn høyre)
  Offset(0.85, 0.90),    // 34
  Offset(0.80, 0.90),    // 35
  Offset(0.75, 0.85),    // 36
  Offset(0.70, 0.80),    // 37
  Offset(0.65, 0.75),    // 38
  Offset(0.60, 0.70),    // 39
  Offset(0.55, 0.65),    // 40
  Offset(0.50, 0.65),    // 41 midten
  Offset(0.45, 0.65),    // 42
  Offset(0.40, 0.70),    // 43
  Offset(0.35, 0.75),    // 44
  Offset(0.30, 0.80),    // 45
  Offset(0.25, 0.85),    // 46
  Offset(0.20, 0.90),    // 47
  Offset(0.15, 0.90),    // 48

  // Venstre (Bunn til topp)
  Offset(0.10, 0.90),    // 49 (hjørne bunn venstre)
  Offset(0.10, 0.85),    // 50
  Offset(0.10, 0.80),    // 51
  Offset(0.15, 0.75),    // 52
  Offset(0.20, 0.70),    // 53
  Offset(0.25, 0.65),    // 54
  Offset(0.30, 0.60),    // 55
  Offset(0.35, 0.55),    // 56
  Offset(0.35, 0.50),    // 57 midten
  Offset(0.35, 0.45),    // 58
  Offset(0.30, 0.40),    // 59
  Offset(0.25, 0.35),    // 60
  Offset(0.20, 0.30),    // 61
  Offset(0.15, 0.25),    // 62
  Offset(0.10, 0.20),    // 63
  Offset(0.10, 0.15),    // 64
];


      String type = ((i == 0) || (i == 16) || (i == 32) || (i == 48)) ? 'immunity' : 'normal';
      return Field(coords[i], type);
    });
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

        double baseFieldSize = boardSide * 0.05; // 5.5% av brettet
        double immunityMultiplier = 1.2; // Immunfelt litt større
        double pieceSize = baseFieldSize * 0.8; // Størrelse på brikken

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
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 4),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
            ),
            // Felt
            ...fields.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              final pos = Offset(
                boardOrigin.dx + f.relPos.dx * boardSide,
                boardOrigin.dy + f.relPos.dy * boardSide,
              );
              double size = f.type == 'immunity'
                  ? baseFieldSize * immunityMultiplier
                  : baseFieldSize;
              return Positioned(
                left: pos.dx - size / 2,
                top: pos.dy - size / 2,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: f.type == 'immunity' ? Colors.orange : Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: size * 0.14),
                  ),
                ),
              );
            }),
            // Brikke
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
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
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
            // Knapp for å flytte brikken
            Positioned(
              left: 30,
              bottom: 30,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentPos = (currentPos + 1) % fields.length;
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
