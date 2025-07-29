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
        Offset(0.10, 0.10), // 1
        Offset(0.18, 0.10), // 2
        Offset(0.26, 0.10), // 3
        Offset(0.34, 0.10), // 4
        Offset(0.42, 0.10), // 5
        Offset(0.50, 0.10), // 6
        Offset(0.58, 0.10), // 7
        Offset(0.66, 0.10), // 8
        Offset(0.74, 0.10), // 9
        Offset(0.82, 0.10), // 10
        Offset(0.90, 0.10), // 11
        Offset(0.90, 0.18), // 12
        Offset(0.90, 0.26), // 13
        Offset(0.90, 0.34), // 14
        Offset(0.90, 0.42), // 15
        Offset(0.90, 0.50), // 16
        Offset(0.90, 0.58), // 17 (IMMU)
        Offset(0.90, 0.66), // 18
        Offset(0.90, 0.74), // 19
        Offset(0.90, 0.82), // 20
        Offset(0.90, 0.90), // 21
        Offset(0.82, 0.90), // 22
        Offset(0.74, 0.90), // 23
        Offset(0.66, 0.90), // 24
        Offset(0.58, 0.90), // 25
        Offset(0.50, 0.90), // 26
        Offset(0.42, 0.90), // 27
        Offset(0.34, 0.90), // 28
        Offset(0.26, 0.90), // 29
        Offset(0.18, 0.90), // 30
        Offset(0.10, 0.90), // 31
        Offset(0.10, 0.82), // 32
        Offset(0.10, 0.74), // 33 (IMMU)
        Offset(0.10, 0.66), // 34
        Offset(0.10, 0.58), // 35
        Offset(0.10, 0.50), // 36
        Offset(0.10, 0.42), // 37
        Offset(0.10, 0.34), // 38
        Offset(0.10, 0.26), // 39
        Offset(0.10, 0.18), // 40
        Offset(0.18, 0.18), // 41
        Offset(0.26, 0.18), // 42
        Offset(0.34, 0.18), // 43
        Offset(0.42, 0.18), // 44
        Offset(0.50, 0.18), // 45
        Offset(0.58, 0.18), // 46
        Offset(0.66, 0.18), // 47
        Offset(0.74, 0.18), // 48
        Offset(0.82, 0.18), // 49 (IMMU)
        Offset(0.82, 0.26), // 50
        Offset(0.82, 0.34), // 51
        Offset(0.82, 0.42), // 52
        Offset(0.82, 0.50), // 53
        Offset(0.82, 0.58), // 54
        Offset(0.82, 0.66), // 55
        Offset(0.82, 0.74), // 56
        Offset(0.82, 0.82), // 57
        Offset(0.74, 0.82), // 58
        Offset(0.66, 0.82), // 59
        Offset(0.58, 0.82), // 60
        Offset(0.50, 0.82), // 61
        Offset(0.42, 0.82), // 62
        Offset(0.34, 0.82), // 63
        Offset(0.26, 0.82), // 64
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

        double baseFieldSize = boardSide * 0.055; // 5.5% av brettet
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
