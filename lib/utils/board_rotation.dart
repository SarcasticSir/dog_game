// lib\utils\board_rotation.dart


import 'dart:math';

double getBoardRotation(int playerNum) {
  // Standard: (playerNum-1) * 90 grader, men VENSTRE skal være din start.
  // Så vi roterer EN kvart runde TIL:
  return -((playerNum - 1) * (pi / 2) + (pi / 2));
}