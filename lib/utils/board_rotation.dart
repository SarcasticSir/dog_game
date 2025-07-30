import 'dart:math';

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
