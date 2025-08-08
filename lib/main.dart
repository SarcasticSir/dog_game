// lib/main.dart
import 'package:flutter/material.dart';
import 'widgets/dog_board.dart';

void main() => runApp(const DogGameApp());

class DogGameApp extends StatelessWidget {
  const DogGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 124, 159, 199),
        body: SafeArea(child: DogBoard()),
      ),
    );
  }
}
