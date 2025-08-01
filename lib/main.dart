import 'package:flutter/material.dart';
import 'widgets/dog_board.dart';
import 'dog_card.dart';


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
