import 'package:flutter/material.dart';

class Field {
  final Offset relPos;
  final String type; // 'normal', 'immunity', 'start', 'goal'
  final int? startNumber;
  final int? player;
  final int? goalNumber;
  Field(this.relPos, this.type, {this.startNumber, this.player, this.goalNumber});
}
