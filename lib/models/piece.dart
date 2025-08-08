// lib/models/piece.dart

class DogPiece {
  final int player;    // Spiller-ID (1–4)
  int fieldIndex;      // Hvor på brettet brikken står (startfelt eller posisjon 0–63)
  bool isImmune;       // True dersom brikken nettopp har gått ut av start og ikke kan passeres/slås ut

  DogPiece({
    required this.player,
    required this.fieldIndex,
    this.isImmune = false,
  });
}
