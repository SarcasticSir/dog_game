
class DogPiece {
  final int player; // 1–4
  int fieldIndex;   // Hvor på brettet brikken står (start: egne startfelt, -1 = i "hånda"/ute)
  DogPiece({required this.player, required this.fieldIndex});
}
