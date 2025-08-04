import 'dart:math';
import 'package:flutter/material.dart';

import '../models/field.dart';
import '../game_manager.dart';
import '../utils/board_rotation.dart';
import 'octagon_painter.dart';
import 'diamond_painter.dart';
import 'player_hand_box.dart';
import 'center_box.dart';
import 'dog_piece_widget.dart';
import '../dog_card.dart';
import '../models/piece.dart';

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  late GameManager gameManager;

  DogCard? selectedCard;
  DogCard? hoveredCard;
  DogPiece? selectedPiece;
  int? selectedMoveValue; // Brukes kun ved 4-kort

  int myPlayerNumber = 1;

  final Map<int, Color> playerStartColor = {
    1: Colors.red,
    2: Colors.blue,
    3: Colors.yellow,
    4: Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    fields = _manualFields();
    gameManager = GameManager(fields: fields);
    myPlayerNumber = gameManager.currentPlayer;
  }

  Set<DogPiece> getMovablePieces(int player) {
    final moves = gameManager.getPossibleMovesForPlayer(player);
    return moves.map((m) => m.piece).toSet();
  }

  Set<DogCard> getPlayableCards(DogPiece? piece) {
    if (piece == null) return {};
    return gameManager.playerHands[myPlayerNumber - 1]
        .where((card) => gameManager.canPieceMove(piece, card))
        .toSet();
  }

  DogPiece? getTargetedEnemyPiece({int? moveValueOverride}) {
    if (selectedCard == null || selectedPiece == null) return null;

    int player = myPlayerNumber;
    DogPiece piece = selectedPiece!;
    Field field = fields[piece.fieldIndex];

    int boardMainFieldIndex = fields.asMap().entries
        .firstWhere((entry) =>
            entry.value.player == player && entry.value.type == 'immunity')
        .key;

    int newFieldIndex;
    int boardSize = 64;
    int? moveValue;
    if (selectedCard!.rank == 4) {
      // Bruk valgt retning hvis valgt
      moveValue = moveValueOverride ?? selectedMoveValue;
      if (moveValue == null) return null;
    } else {
      moveValue = selectedCard!.rank ?? 0;
    }

    if (field.type == 'start') {
      if (selectedCard!.rank == 1 ||
          selectedCard!.rank == 13 ||
          selectedCard!.suit == Suit.joker) {
        newFieldIndex = boardMainFieldIndex;
      } else {
        return null;
      }
    } else {
      newFieldIndex = piece.fieldIndex + moveValue;
      if (newFieldIndex >= boardSize) {
        newFieldIndex = newFieldIndex % boardSize;
      } else if (newFieldIndex < 0) {
        newFieldIndex = boardSize + newFieldIndex;
      }
    }

    final occupyingPiece = gameManager.pieces.firstWhere(
      (p) => p.fieldIndex == newFieldIndex,
      orElse: () => DogPiece(player: -1, fieldIndex: -1),
    );
    if (occupyingPiece.player != -1 && occupyingPiece.player != myPlayerNumber) {
      return occupyingPiece;
    }
    return null;
  }

  void _handleCardTap(DogCard card) {
    if (selectedPiece == null) {
      print("Velg en brikke først.");
      return;
    }
    if (gameManager.currentPlayer != myPlayerNumber) {
      print("Det er ikke din tur.");
      return;
    }
    final playable = getPlayableCards(selectedPiece).contains(card);
    if (!playable) return;

    setState(() {
      if (selectedCard == card) {
        selectedCard = null;
        selectedMoveValue = null;
      } else {
        selectedCard = card;
        selectedMoveValue = null;
      }
    });
  }

  void _handlePieceTap(DogPiece piece) {
    if (piece.player != gameManager.currentPlayer) return;
    final movable = getMovablePieces(myPlayerNumber).contains(piece);
    if (!movable) return;
    setState(() {
      if (selectedPiece == piece) {
        selectedPiece = null;
        selectedCard = null;
        selectedMoveValue = null;
      } else {
        selectedPiece = piece;
        selectedCard = null;
        selectedMoveValue = null;
      }
    });
  }

  void _handleMoveChoice(int value) {
    setState(() {
      selectedMoveValue = value;
    });
  }

 void _handlePlayCardButton() {
  if (selectedCard != null && selectedPiece != null) {
    int moveValue = selectedCard!.rank ?? 0;
    if (selectedCard!.rank == 4) {
      if (selectedMoveValue == null) {
        print("Velg retning for 4-kortet.");
        return;
      }
      moveValue = selectedMoveValue!;
    }

    final bool moveSuccessful = gameManager.playCard(
      gameManager.currentPlayer,
      selectedCard!,
      selectedPiece!,
      moveValue,
    );

    if (moveSuccessful) {
      setState(() {
        selectedCard = null;
        selectedPiece = null;
        selectedMoveValue = null;
        myPlayerNumber = gameManager.currentPlayer;
      });
    } else {
      print("Ugyldig trekk med valgt kort og brikke.");
    }
  }
}
  void _handlePassButton() {
    setState(() {
      gameManager.passTurn();
      myPlayerNumber = gameManager.currentPlayer;
      selectedCard = null;
      selectedPiece = null;
      selectedMoveValue = null;
    });
  }

  List<Field> _manualFields() {
    final coords = [
      Offset(0.10, 0.10), Offset(0.15, 0.10), Offset(0.20, 0.10), Offset(0.25, 0.15), Offset(0.30, 0.20), Offset(0.35, 0.25), Offset(0.40, 0.30),
      Offset(0.45, 0.35), Offset(0.50, 0.35), Offset(0.55, 0.35), Offset(0.60, 0.30), Offset(0.65, 0.25), Offset(0.70, 0.20), Offset(0.75, 0.15),
      Offset(0.80, 0.10), Offset(0.85, 0.10), Offset(0.90, 0.10), Offset(0.90, 0.15), Offset(0.90, 0.20), Offset(0.85, 0.25), Offset(0.80, 0.30),
      Offset(0.75, 0.35), Offset(0.70, 0.40), Offset(0.65, 0.45), Offset(0.65, 0.50), Offset(0.65, 0.55), Offset(0.70, 0.60), Offset(0.75, 0.65),
      Offset(0.80, 0.70), Offset(0.85, 0.75), Offset(0.90, 0.80), Offset(0.90, 0.85), Offset(0.90, 0.90), Offset(0.85, 0.90), Offset(0.80, 0.90),
      Offset(0.75, 0.85), Offset(0.70, 0.80), Offset(0.65, 0.75), Offset(0.60, 0.70), Offset(0.55, 0.65), Offset(0.50, 0.65), Offset(0.45, 0.65),
      Offset(0.40, 0.70), Offset(0.35, 0.75), Offset(0.30, 0.80), Offset(0.25, 0.85), Offset(0.20, 0.90), Offset(0.15, 0.90), Offset(0.10, 0.90),
      Offset(0.10, 0.85), Offset(0.10, 0.80), Offset(0.15, 0.75), Offset(0.20, 0.70), Offset(0.25, 0.65), Offset(0.30, 0.60), Offset(0.35, 0.55),
      Offset(0.35, 0.50), Offset(0.35, 0.45), Offset(0.30, 0.40), Offset(0.25, 0.35), Offset(0.20, 0.30), Offset(0.15, 0.25), Offset(0.10, 0.20),
      Offset(0.10, 0.15),
    ];
    final List<Field> startFields = [
      Field(Offset(0.04, 0.08), 'start', startNumber: 1, player: 1),
      Field(Offset(0.04, 0.14), 'start', startNumber: 2, player: 1),
      Field(Offset(0.04, 0.20), 'start', startNumber: 3, player: 1),
      Field(Offset(0.04, 0.26), 'start', startNumber: 4, player: 1),
      Field(Offset(0.92, 0.04), 'start', startNumber: 1, player: 2),
      Field(Offset(0.86, 0.04), 'start', startNumber: 2, player: 2),
      Field(Offset(0.80, 0.04), 'start', startNumber: 3, player: 2),
      Field(Offset(0.74, 0.04), 'start', startNumber: 4, player: 2),
      Field(Offset(0.96, 0.92), 'start', startNumber: 1, player: 3),
      Field(Offset(0.96, 0.86), 'start', startNumber: 2, player: 3),
      Field(Offset(0.96, 0.80), 'start', startNumber: 3, player: 3),
      Field(Offset(0.96, 0.74), 'start', startNumber: 4, player: 3),
      Field(Offset(0.08, 0.96), 'start', startNumber: 1, player: 4),
      Field(Offset(0.14, 0.96), 'start', startNumber: 2, player: 4),
      Field(Offset(0.20, 0.96), 'start', startNumber: 3, player: 4),
      Field(Offset(0.26, 0.96), 'start', startNumber: 4, player: 4),
    ];
    final List<Field> goalFields = [
      Field(Offset(0.17, 0.17), 'goal', goalNumber: 1, player: 1),
      Field(Offset(0.21, 0.21), 'goal', goalNumber: 2, player: 1),
      Field(Offset(0.25, 0.25), 'goal', goalNumber: 3, player: 1),
      Field(Offset(0.29, 0.29), 'goal', goalNumber: 4, player: 1),
      Field(Offset(0.83, 0.17), 'goal', goalNumber: 1, player: 2),
      Field(Offset(0.79, 0.21), 'goal', goalNumber: 2, player: 2),
      Field(Offset(0.75, 0.25), 'goal', goalNumber: 3, player: 2),
      Field(Offset(0.71, 0.29), 'goal', goalNumber: 4, player: 2),
      Field(Offset(0.83, 0.83), 'goal', goalNumber: 1, player: 3),
      Field(Offset(0.79, 0.79), 'goal', goalNumber: 2, player: 3),
      Field(Offset(0.75, 0.75), 'goal', goalNumber: 3, player: 3),
      Field(Offset(0.71, 0.71), 'goal', goalNumber: 4, player: 3),
      Field(Offset(0.17, 0.83), 'goal', goalNumber: 1, player: 4),
      Field(Offset(0.21, 0.79), 'goal', goalNumber: 2, player: 4),
      Field(Offset(0.25, 0.75), 'goal', goalNumber: 3, player: 4),
      Field(Offset(0.29, 0.71), 'goal', goalNumber: 4, player: 4),
    ];
    return [
      for (int i = 0; i < coords.length; i++)
        Field(
          coords[i],
          ((i == 0) || (i == 16) || (i == 32) || (i == 48))
              ? 'immunity'
              : 'normal',
          player: (i == 0)
              ? 1
              : (i == 16)
                  ? 2
                  : (i == 32)
                      ? 3
                      : (i == 48)
                          ? 4
                          : null,
        ),
      ...startFields,
      ...goalFields,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool canMove = gameManager.getPossibleMovesForPlayer(myPlayerNumber).isNotEmpty;
    final bool isMyTurn = gameManager.currentPlayer == myPlayerNumber;
    final bool canPlayCard = isMyTurn && selectedCard != null && selectedPiece != null;

    final movablePieces = getMovablePieces(myPlayerNumber);
    final targetedEnemyPiece = getTargetedEnemyPiece();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= constraints.maxHeight * 1.3) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.screen_rotation,
                  size: 100,
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                Text(
                  'Vennligst roter enheten din for å spille',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final double boardSide = constraints.biggest.shortestSide * 0.85;
        double baseFieldSize = boardSide * 0.05;
        double immunityMultiplier = 1.2;
        double startMultiplier = 1.13;
        double pieceSize = baseFieldSize * 0.8;
        final double boxWidth = boardSide * 0.23;
        final double boxHeight = boxWidth * 0.60;
        final double cardWidth = boardSide * 0.12;
        final double cardHeight = cardWidth * 1.4;
        final double handCardSpacing = cardWidth * 0.05;
        final double buttonFontSize = constraints.maxHeight * 0.025;

        List<int> boxOrder = [
          myPlayerNumber,
          (myPlayerNumber % 4) + 1,
          ((myPlayerNumber + 1) % 4) + 1,
          ((myPlayerNumber + 2) % 4) + 1,
        ];

        final Color playerColor = playerStartColor[myPlayerNumber]!;
        final Color hoverColor = playerColor.withAlpha(51);

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ---- KNAPPER START ----
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // 4-kort: Velg frem/bak-knapper vertikalt, deretter bekreft
                            if (canPlayCard && selectedCard != null && selectedCard!.rank == 4 && selectedMoveValue == null)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _handleMoveChoice(4),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Fremover (+4)',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _handleMoveChoice(-4),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      'Bakover (-4)',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else if (canPlayCard && selectedCard != null && selectedCard!.rank == 4 && selectedMoveValue != null)
                              ElevatedButton(
                                onPressed: _handlePlayCardButton,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Bekreft trekk',
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Visibility(
                                visible: canPlayCard,
                                child: ElevatedButton(
                                  onPressed: _handlePlayCardButton,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    'Spill kort',
                                    style: TextStyle(
                                      fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            Visibility(
                              visible: isMyTurn && !canMove,
                              child: ElevatedButton(
                                onPressed: _handlePassButton,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 5,
                                ),
                                child: Text(
                                  'Pass Tur',
                                  style: TextStyle(
                                    fontSize: buttonFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // ---- KNAPPER SLUTT ----
                        const SizedBox(width: 20),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: cardWidth * 1.2,
                              height: cardHeight * 1.2,
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Stack(
                                children: [
                                  for (int i = 2; i >= 0; i--)
                                    Positioned(
                                      left: i.toDouble() * cardWidth * 0.05,
                                      top: i.toDouble() * cardHeight * 0.05,
                                      child: Container(
                                        width: cardWidth,
                                        height: cardHeight,
                                        decoration: BoxDecoration(
                                          color: i == 0
                                              ? Colors.white
                                              : Colors.grey[300],
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 7,
                                              offset: Offset(2, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    left: cardWidth * 0.05,
                                    top: cardHeight * 0.1,
                                    child: SizedBox(
                                      width: cardWidth * 0.9,
                                      height: cardHeight * 0.9,
                                      child: Center(
                                        child: Icon(
                                          Icons.style,
                                          size: cardWidth * 0.8,
                                          color: Colors.blueGrey[300],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: cardWidth,
                              height: cardHeight * 0.4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(color: Colors.black12, blurRadius: 3),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${gameManager.deck.length} kort igjen',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: cardWidth * 0.15,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (row) {
                        int startIdx = row * 2;
                        final hand = gameManager.playerHands[myPlayerNumber - 1];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: handCardSpacing),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(2, (col) {
                              int cardIdx = startIdx + col;
                              if (cardIdx >= hand.length) {
                                return SizedBox(
                                  width: cardWidth + handCardSpacing,
                                  height: cardHeight + handCardSpacing,
                                );
                              }
                              final card = hand[cardIdx];
                              final isSelected = card == selectedCard;
                              final playableCards = getPlayableCards(selectedPiece);
                              final isPlayable = selectedPiece != null && playableCards.contains(card);

                              return MouseRegion(
                                cursor: (isPlayable && selectedPiece != null)
                                    ? SystemMouseCursors.click
                                    : SystemMouseCursors.forbidden,
                                onEnter: (_) {
                                  setState(() {
                                    hoveredCard = card;
                                  });
                                },
                                onExit: (_) {
                                  setState(() {
                                    if (hoveredCard == card) hoveredCard = null;
                                  });
                                },
                                child: GestureDetector(
                                  onTap: () {
                                    if (isPlayable && selectedPiece != null) {
                                      _handleCardTap(card);
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 100),
                                        width: cardWidth,
                                        height: cardHeight,
                                        margin: EdgeInsets.symmetric(
                                          horizontal: handCardSpacing,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.orange
                                              : (hoveredCard == card && isPlayable)
                                                  ? hoverColor
                                                  : Colors.white,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.orange
                                                : (isPlayable
                                                    ? Colors.green
                                                    : Colors.black26),
                                            width: isSelected
                                                ? 3
                                                : (isPlayable ? 2.3 : 1.5),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: Colors.orange,
                                                blurRadius: 7,
                                                offset: const Offset(0, 2),
                                              ),
                                            if (hoveredCard == card && !isSelected && isPlayable)
                                              BoxShadow(
                                                color: playerColor.withAlpha(51),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            card.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: cardWidth * 0.25,
                                              color: card.suit == Suit.hearts || card.suit == Suit.diamonds
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              // Midten av Row: Spillbrettet og spillerboksene
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: getBoardRotation(myPlayerNumber),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Brettet
                        Container(
                          width: boardSide,
                          height: boardSide,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 4,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                        // FELTER
                        ...fields.asMap().entries.map((entry) {
                          final f = entry.value;
                          final pos = Offset(
                            f.relPos.dx * boardSide,
                            f.relPos.dy * boardSide,
                          );
                          double size = baseFieldSize;
                          if (f.type == 'immunity') size *= immunityMultiplier;
                          if (f.type == 'start') size *= startMultiplier;

                          Color color;
                          if (f.type == 'immunity') {
                            color = Colors.black; // Endret til sort
                          } else if (f.type == 'goal' ||
                              f.type == 'start') {
                            color = playerStartColor[f.player] ?? Colors.green;
                          } else {
                            color = Colors.black;
                          }

                          Widget? label;
                          if (f.type == 'goal') {
                            label = Transform.rotate(
                              angle: -getBoardRotation(myPlayerNumber),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${f.goalNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: size * 0.6,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          } else if (f.type == 'start') {
                            label = Transform.rotate(
                              angle: -getBoardRotation(myPlayerNumber),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  '${f.startNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: size * 0.6,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }

                          return Positioned(
                            left: pos.dx - size / 2,
                            top: pos.dy - size / 2,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (f.type == 'start')
                                  CustomPaint(
                                    size: Size(size, size),
                                    painter: OctagonPainter(color),
                                  )
                                else
                                  Container(
                                    width: size,
                                    height: size,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: size * 0.14,
                                      ),
                                    ),
                                  ),
                                if (f.type == 'goal')
                                  CustomPaint(
                                    size: Size(size, size),
                                    painter: DiamondPainter(color),
                                  ),
                                if (label != null) label,
                              ],
                            ),
                          );
                        }),
                        // BRIKKER
                        ...gameManager.pieces.map((piece) {
                          final field = fields[piece.fieldIndex];
                          final pos = Offset(
                            field.relPos.dx * boardSide,
                            field.relPos.dy * boardSide,
                          );
                          final bool isMine = piece.player == myPlayerNumber;
                          final bool isSelected = selectedPiece == piece;
                          final bool canMovePiece = movablePieces.contains(piece);

                          // Outline-farge
                          Color outlineColor;
                          if (isMine && canMovePiece && isMyTurn) {
                            outlineColor = isSelected ? Colors.orange : Colors.green;
                          } else if (!isMine) {
                            outlineColor = Colors.grey;
                          } else {
                            outlineColor = Colors.grey.shade300;
                          }

                          // Hodeskalle-visning hvis brikke slås ut
                          bool showSkull = false;
                          if (targetedEnemyPiece != null && piece == targetedEnemyPiece) {
                            showSkull = true;
                          }

                          Widget pieceWidget;
                          if (showSkull) {
                            pieceWidget = Center(
                              child: Text(
                                "💀",
                                style: TextStyle(
                                  fontSize: pieceSize * 0.95,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Colors.black.withAlpha(180),
                                      offset: Offset(1, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          } else {
                            pieceWidget = DogPieceWidget(
                              color: playerStartColor[piece.player] ?? Colors.black,
                              size: pieceSize,
                              isSelected: isSelected,
                              isInPlay: field.type != 'start',
                              outlineColor: outlineColor,
                            );
                          }

                          // Gjør brikken klikkbar hvis det er din og du kan flytte den
                          if (isMine && canMovePiece && isMyTurn && !showSkull) {
                            pieceWidget = GestureDetector(
                              onTap: () => _handlePieceTap(piece),
                              child: pieceWidget,
                            );
                          }

                          return Positioned(
                            left: pos.dx - pieceSize / 2,
                            top: pos.dy - pieceSize / 2,
                            child: pieceWidget,
                          );
                        }),
                        Transform.rotate(
                          angle: -getBoardRotation(myPlayerNumber),
                          child: CenterBox(width: boardSide * 0.25),
                        ),
                      ],
                    ),
                  ),
                  // Spillernes handbokser
                  Positioned(
                    bottom: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: PlayerHandBox(
                      player: boxOrder[0],
                      width: boxWidth,
                      isMe: true,
                      isCurrentPlayer: gameManager.currentPlayer == boxOrder[0],
                      hand: gameManager.playerHands[boxOrder[0] - 1],
                    ),
                  ),
                  Positioned(
                    left: -boxHeight * 0.2,
                    top: (boardSide - boxWidth) / 2 + (boxWidth * 0.2),
                    child: Transform.rotate(
                      angle: -pi / 2,
                      child: PlayerHandBox(
                        player: boxOrder[1],
                        width: boxWidth,
                        isCurrentPlayer: gameManager.currentPlayer == boxOrder[1],
                        hand: gameManager.playerHands[boxOrder[1] - 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: Transform.rotate(
                      angle: pi * 2,
                      child: PlayerHandBox(
                        player: boxOrder[2],
                        width: boxWidth,
                        isCurrentPlayer: gameManager.currentPlayer == boxOrder[2],
                        hand: gameManager.playerHands[boxOrder[2] - 1],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -boxHeight * 0.2,
                    top: (boardSide - boxWidth) / 2 + (boxWidth * 0.2),
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: PlayerHandBox(
                        player: boxOrder[3],
                        width: boxWidth,
                        isCurrentPlayer: gameManager.currentPlayer == boxOrder[3],
                        hand: gameManager.playerHands[boxOrder[3] - 1],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
