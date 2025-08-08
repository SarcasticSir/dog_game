// lib/models/field.dart

import 'package:flutter/material.dart';

class Field {
  final Offset relPos;    // Relativ posisjon på brettet (0–1 koordinater)
  final String type;      // 'normal', 'immunity', 'start', 'goal'
  final int? startNumber; // Nummer for startfelt (1–4) om type = 'start'
  final int? player;      // Hvilken spiller feltet tilhører (for start/immunity/goal)
  final int? goalNumber;  // Nummer for mål (1–4) om type = 'goal'

  Field(this.relPos, this.type, {this.startNumber, this.player, this.goalNumber});
}
