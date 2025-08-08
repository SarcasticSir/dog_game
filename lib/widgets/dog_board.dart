import 'dart:math';
import 'package:flutter/material.dart';

import '../models/field.dart';
import '../game_manager.dart' as gm;
import '../utils/board_rotation.dart';
import 'octagon_painter.dart';
import 'diamond_painter.dart';
import 'player_hand_box.dart';
import 'center_box.dart';
import 'dog_piece_widget.dart';
import '../dog_card.dart';
import '../models/piece.dart';

class SevenMoveStep {
  final DogPiece piece;
  final int steps;
  final int fromIndex;
  final int toIndex;
  SevenMoveStep(this.piece, this.steps, this.fromIndex, this.toIndex);
}

class DogBoard extends StatefulWidget {
  const DogBoard({super.key});
  @override
  State<DogBoard> createState() => _DogBoardState();
}

class _DogBoardState extends State<DogBoard> {
  late List<Field> fields;
  late gm.GameManager gameManager;

  DogCard? selectedCard;
  DogPiece? selectedPiece;
  int? selectedMoveValue;
  int? selectedJokerRank; // NEW: which rank the joker will mimic, if chosen

  int myPlayerNumber = 1;

  bool inSevenMode = false;
  int remainingSevenSteps = 7;
  List<SevenMoveStep> sevenMoves = [];
  DogPiece? currentSevenPiece;

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
    gameManager = gm.GameManager(fields: fields);
    myPlayerNumber = gameManager.currentPlayer;
  }

  Set<DogPiece> getMovablePieces(int player) {
    final moves = gameManager.getPossibleMovesForPlayer(player);
    return moves.map((m) => m.piece).toSet();
  }

  Set<DogCard> getPlayableCards(DogPiece? piece) {
    if (piece == null) return {};
    return gameManager
        .handOf(myPlayerNumber)
        .where((card) => gameManager.canPieceMove(piece, card))
        .toSet();
  }

  DogPiece? getTargetedEnemyPiece({int? moveValueOverride}) {
    if (selectedCard == null || selectedPiece == null) return null;
    if (selectedCard!.rank == 7) return null; // handled in seven mode

    int player = myPlayerNumber;
    DogPiece piece = selectedPiece!;
    Field field = fields[piece.fieldIndex];

    int newFieldIndex;
    int boardSize = 64;
    int? moveValue;

    if (selectedCard!.suit == Suit.joker) {
      // Joker: use selectedJokerRank and selectedMoveValue
      final rank = selectedJokerRank;
      if (rank == null) return null;
      // 4 and 1 may have ±/multi choices
      if (rank == 4) {
        moveValue = moveValueOverride ?? selectedMoveValue;
        if (moveValue == null) return null;
      } else if (rank == 1) {
        // Ace chosen via joker
        // If piece is in start, move out; no capture
        if (field.type == 'start') {
          int boardMainFieldIndex = fields.asMap().entries
              .firstWhere((entry) =>
                  entry.value.player == player &&
                  entry.value.type == 'immunity')
              .key;
          final occupyingPiece = gameManager.pieces.firstWhere(
            (p) => p.fieldIndex == boardMainFieldIndex,
            orElse: () => DogPiece(player: -1, fieldIndex: -1),
          );
          if (occupyingPiece.player != -1 &&
              occupyingPiece.player != myPlayerNumber) {
            return occupyingPiece;
          }
          return null;
        }
        moveValue = moveValueOverride ?? selectedMoveValue;
        if (moveValue == null) return null;
      } else {
        moveValue = rank;
      }
    } else if (selectedCard!.rank == 4) {
      moveValue = moveValueOverride ?? selectedMoveValue;
      if (moveValue == null) return null;
    } else if (selectedCard!.rank == 1) {
      if (field.type == 'start') {
        int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) =>
                entry.value.player == player &&
                entry.value.type == 'immunity')
            .key;
        final occupyingPiece = gameManager.pieces.firstWhere(
          (p) => p.fieldIndex == boardMainFieldIndex,
          orElse: () => DogPiece(player: -1, fieldIndex: -1),
        );
        if (occupyingPiece.player != -1 &&
            occupyingPiece.player != myPlayerNumber) {
          return occupyingPiece;
        }
        return null;
      }
      moveValue = moveValueOverride ?? selectedMoveValue;
      if (moveValue == null) return null;
    } else {
      moveValue = selectedCard!.rank ?? 0;
    }

    if (moveValue == 0) return null;

    if (field.type == 'start') {
      int boardMainFieldIndex = fields.asMap().entries
          .firstWhere((entry) =>
              entry.value.player == player && entry.value.type == 'immunity')
          .key;
      newFieldIndex = boardMainFieldIndex;
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
    if (occupyingPiece.player != -1 &&
        occupyingPiece.player != myPlayerNumber) {
      return occupyingPiece;
    }
    return null;
  }

  void _resetSevenMode({bool keepCard = false}) {
    for (final s in sevenMoves) {
      s.piece.fieldIndex = s.fromIndex;
    }
    inSevenMode = false;
    remainingSevenSteps = 7;
    currentSevenPiece = null;
    sevenMoves.clear();
    selectedMoveValue = null;
    selectedJokerRank = null;
    if (!keepCard) {
      selectedCard = null;
      selectedPiece = null;
    }
  }

  Future<void> _promptJokerValueSelection() async {
    final DogPiece? piece = selectedPiece;
    final DogCard? card = selectedCard;
    if (piece == null || card == null) return;
    // Build list of valid ranks (Ace=1, etc.)
    final List<int> candidateValues = [
      -4,
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
    ];
    final List<int> validValues = [];
    for (final v in candidateValues) {
      if (gameManager.canPieceMoveWithValue(piece, card, v)) {
        validValues.add(v);
      }
    }
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Vennligst velg verdi på jokeren'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final v in validValues)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        setState(() {
                          selectedJokerRank = v;
                          selectedMoveValue = null;
                        });
                        // If 7, enter seven-mode; otherwise 4/1 will show selection UI
                      },
                      child: Text(v == -4 ? '-4' : v.toString()),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Avbryt'),
                ),
              ],
            ),
          ),
        );
      },
    );
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

    final bool wasSame = selectedCard == card;
    if (inSevenMode || sevenMoves.isNotEmpty) {
      _resetSevenMode();
    }
    setState(() {
      if (wasSame) {
        selectedCard = null;
        selectedMoveValue = null;
        selectedJokerRank = null;
      } else {
        selectedCard = card;
        selectedMoveValue = null;
        selectedJokerRank = null;
        if (card.rank == 7) {
          inSevenMode = true;
          sevenMoves.clear();
          remainingSevenSteps = 7;
          currentSevenPiece = null;
        } else {
          inSevenMode = false;
          sevenMoves.clear();
          currentSevenPiece = null;
        }
      }
    });
  }

  void _handlePieceTap(DogPiece piece) {
    if (!inSevenMode) {
      if (piece.player != gameManager.currentPlayer) return;
      final movable = getMovablePieces(myPlayerNumber).contains(piece);
      if (!movable) return;
      setState(() {
        if (selectedPiece == piece) {
          selectedPiece = null;
          selectedCard = null;
          selectedMoveValue = null;
          selectedJokerRank = null;
        } else {
          selectedPiece = piece;
          selectedCard = null;
          selectedMoveValue = null;
          selectedJokerRank = null;
        }
      });
    } else {
      if (piece.player != myPlayerNumber) return;
      setState(() {
        currentSevenPiece = piece;
      });
    }
  }

  void _handleMoveChoice(int value) {
    setState(() {
      selectedMoveValue = value;
    });
  }

  void _handleSevenFieldTap(int toIndex) {
    if (currentSevenPiece == null || !inSevenMode) return;
    int fromIndex = currentSevenPiece!.fieldIndex;
    int steps = (toIndex - fromIndex + 64) % 64;
    if (steps == 0 || steps > remainingSevenSteps) return;
    // Validate path
    bool valid = true;
    for (int i = 1; i <= steps; i++) {
      int pos = (fromIndex + i) % 64;
      final occupant = gameManager.pieces.firstWhere(
        (p) => p.fieldIndex == pos,
        orElse: () => DogPiece(player: -1, fieldIndex: -1),
      );
      if (i < steps) {
        if (occupant.player == myPlayerNumber && occupant.player != -1) {
          valid = false;
          break;
        }
        if (occupant.player != -1 && occupant.isImmune) {
          valid = false;
          break;
        }
      }
      if (i == steps) {
        if (occupant.player == myPlayerNumber) {
          valid = false;
          break;
        }
        if (occupant.player != -1 && occupant.isImmune) {
          valid = false;
          break;
        }
      }
    }
    if (!valid) return;
    currentSevenPiece!.fieldIndex = toIndex;
    setState(() {
      sevenMoves
          .add(SevenMoveStep(currentSevenPiece!, steps, fromIndex, toIndex));
      remainingSevenSteps -= steps;
      currentSevenPiece = null;
    });
  }

  void _handleConfirmSevenMoves() {
    if (!inSevenMode ||
        remainingSevenSteps != 0 ||
        selectedCard == null) {
      return;
    }
    // Wrap return in braces to avoid curly-brace lint
    for (final s in sevenMoves) {
      s.piece.fieldIndex = s.fromIndex;
    }
    final gmSteps = sevenMoves
        .map((s) => gm.SevenMoveStep(
              piece: s.piece,
              fromIndex: s.fromIndex,
              toIndex: s.toIndex,
              steps: s.steps,
            ))
        .toList();
    final bool success =
        gameManager.playSevenCard(myPlayerNumber, selectedCard!, gmSteps);
    if (success) {
      setState(() {
        inSevenMode = false;
        selectedCard = null;
        selectedPiece = null;
        selectedMoveValue = null;
        selectedJokerRank = null;
        remainingSevenSteps = 7;
        sevenMoves.clear();
        currentSevenPiece = null;
        myPlayerNumber = gameManager.currentPlayer;
      });
    } else {
      setState(() {
        sevenMoves.clear();
        remainingSevenSteps = 7;
        currentSevenPiece = null;
      });
    }
  }

  void _handleCancelSeven() {
    _resetSevenMode(keepCard: true);
    setState(() {
      // keep selectedCard and selectedPiece
    });
  }

  void _handlePlayCardButton() {
    if (selectedCard != null && selectedPiece != null) {
      int moveValue;
      if (selectedCard!.suit == Suit.joker) {
        // Piece in start: move out
        final field = fields[selectedPiece!.fieldIndex];
        if (field.type == 'start') {
          moveValue = 1;
        } else {
          // Choose rank if not set
          final rank = selectedJokerRank;
          if (rank == null) {
            _promptJokerValueSelection();
            return;
          }
          if (rank == 7) {
            // Seven mode; no direct play
            return;
          }
          if (rank == 4 || rank == 1) {
            // Need direction or 1/11 selection
            if (selectedMoveValue == null) {
              // Wait for selection
              return;
            }
            moveValue = selectedMoveValue!;
          } else {
            moveValue = rank;
          }
        }
      } else if (selectedCard!.rank == 4) {
        if (selectedMoveValue == null) {
          print("Velg retning for 4-kortet.");
          return;
        }
        moveValue = selectedMoveValue!;
      } else if (selectedCard!.rank == 1) {
        final field = fields[selectedPiece!.fieldIndex];
        if (field.type == 'start') {
          moveValue = 1;
        } else {
          if (selectedMoveValue == null) {
            print("Velg antall steg for esset.");
            return;
          }
          moveValue = selectedMoveValue!;
        }
      } else if (selectedCard!.rank == 7) {
        return;
      } else {
        moveValue = selectedCard!.rank ?? 0;
      }
      final bool moveSuccessful = gameManager.playCard(
        myPlayerNumber,
        selectedCard!,
        selectedPiece!,
        moveValue,
      );
      if (moveSuccessful) {
        setState(() {
          selectedCard = null;
          selectedPiece = null;
          selectedMoveValue = null;
          selectedJokerRank = null;
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
      selectedJokerRank = null;
    });
  }
  /// Defines the positions and types of all board fields. This method
  /// constructs the main loop of 64 positions plus start and goal fields.
  List<Field> _manualFields() {
    final coords = [
      Offset(0.10, 0.10),
      Offset(0.15, 0.10),
      Offset(0.20, 0.10),
      Offset(0.25, 0.15),
      Offset(0.30, 0.20),
      Offset(0.35, 0.25),
      Offset(0.40, 0.30),
      Offset(0.45, 0.35),
      Offset(0.50, 0.35),
      Offset(0.55, 0.35),
      Offset(0.60, 0.30),
      Offset(0.65, 0.25),
      Offset(0.70, 0.20),
      Offset(0.75, 0.15),
      Offset(0.80, 0.10),
      Offset(0.85, 0.10),
      Offset(0.90, 0.10),
      Offset(0.90, 0.15),
      Offset(0.90, 0.20),
      Offset(0.85, 0.25),
      Offset(0.80, 0.30),
      Offset(0.75, 0.35),
      Offset(0.70, 0.40),
      Offset(0.65, 0.45),
      Offset(0.65, 0.50),
      Offset(0.65, 0.55),
      Offset(0.70, 0.60),
      Offset(0.75, 0.65),
      Offset(0.80, 0.70),
      Offset(0.85, 0.75),
      Offset(0.90, 0.80),
      Offset(0.90, 0.85),
      Offset(0.90, 0.90),
      Offset(0.85, 0.90),
      Offset(0.80, 0.90),
      Offset(0.75, 0.85),
      Offset(0.70, 0.80),
      Offset(0.65, 0.75),
      Offset(0.60, 0.70),
      Offset(0.55, 0.65),
      Offset(0.50, 0.65),
      Offset(0.45, 0.65),
      Offset(0.40, 0.70),
      Offset(0.35, 0.75),
      Offset(0.30, 0.80),
      Offset(0.25, 0.85),
      Offset(0.20, 0.90),
      Offset(0.15, 0.90),
      Offset(0.10, 0.90),
      Offset(0.10, 0.85),
      Offset(0.10, 0.80),
      Offset(0.15, 0.75),
      Offset(0.20, 0.70),
      Offset(0.25, 0.65),
      Offset(0.30, 0.60),
      Offset(0.35, 0.55),
      Offset(0.35, 0.50),
      Offset(0.35, 0.45),
      Offset(0.30, 0.40),
      Offset(0.25, 0.35),
      Offset(0.20, 0.30),
      Offset(0.15, 0.25),
      Offset(0.10, 0.20),
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
    final bool canMove =
        gameManager.getPossibleMovesForPlayer(myPlayerNumber).isNotEmpty;
    final bool isMyTurn = gameManager.currentPlayer == myPlayerNumber;
    final bool canPlayCard =
        isMyTurn && selectedCard != null && selectedPiece != null;

    final movablePieces = getMovablePieces(myPlayerNumber);
    final targetedEnemyPiece = getTargetedEnemyPiece();

    // Compute targets and impacted pieces for seven-card mode
    final Set<int> sevenSelectedTargets = {};
    final Set<int> sevenValidTargets = {};
    final Set<DogPiece> sevenTargetedPieces = {};
    if (inSevenMode) {
      // Already chosen seven-move targets
      for (final s in sevenMoves) {
        sevenSelectedTargets.add(s.toIndex);
        // Add pieces along the path to this target
        int fromIdx = s.fromIndex;
        for (int i = 1; i <= s.steps; i++) {
          int pos = (fromIdx + i) % 64;
          final occupier = gameManager.pieces.firstWhere(
            (p) => p.fieldIndex == pos,
            orElse: () => DogPiece(player: -1, fieldIndex: -1),
          );
          if (occupier.player != -1 && occupier.player != myPlayerNumber) {
            sevenTargetedPieces.add(occupier);
          }
        }
      }
      // Valid targets for the current piece being moved
      if (currentSevenPiece != null) {
        int baseFrom = currentSevenPiece!.fieldIndex;
        // Find last destination of this piece in previous seven-moves
        for (final s in sevenMoves.reversed) {
          if (s.piece == currentSevenPiece) {
            baseFrom = s.toIndex;
            break;
          }
        }
        for (int step = 1; step <= remainingSevenSteps; step++) {
          int toIdx = (baseFrom + step) % 64;
          bool valid = true;
          // Validate path
          for (int i = 1; i <= step; i++) {
            int pos = (baseFrom + i) % 64;
            final occupant = gameManager.pieces.firstWhere(
              (p) => p.fieldIndex == pos,
              orElse: () => DogPiece(player: -1, fieldIndex: -1),
            );
            if (i < step) {
              if (occupant.player == myPlayerNumber && occupant.player != -1) {
                valid = false;
                break;
              }
              if (occupant.player != -1 && occupant.isImmune) {
                valid = false;
                break;
              }
            }
            if (i == step) {
              if (occupant.player == myPlayerNumber) {
                valid = false;
                break;
              }
              if (occupant.player != -1 && occupant.isImmune) {
                valid = false;
                break;
              }
            }
          }
          if (valid) {
            sevenValidTargets.add(toIdx);
            final occupying = gameManager.pieces.firstWhere(
              (p) => p.fieldIndex == toIdx,
              orElse: () => DogPiece(player: -1, fieldIndex: -1),
            );
            if (occupying.player != -1 && occupying.player != myPlayerNumber) {
              sevenTargetedPieces.add(occupying);
            }
          }
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Suggest rotating for portrait orientation
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
              // Left side: control buttons and hand
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Special handling for 4-card: choose direction
                            if (canPlayCard &&
                                selectedCard != null &&
                                selectedCard!.rank == 4 &&
                                selectedMoveValue == null)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _handleMoveChoice(4),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
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
                            // Confirm for 4-card after direction chosen
                            else if (canPlayCard &&
                                selectedCard != null &&
                                selectedCard!.rank == 4 &&
                                selectedMoveValue != null)
                              ElevatedButton(
                                onPressed: _handlePlayCardButton,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
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
                            // Ace: choose between 1 and 11 when not leaving start
                            else if (canPlayCard &&
                                selectedCard != null &&
                                selectedCard!.rank == 1 &&
                                selectedPiece != null &&
                                fields[selectedPiece!.fieldIndex].type != 'start' &&
                                selectedMoveValue == null)
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _handleMoveChoice(1),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      '1 steg',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _handleMoveChoice(11),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: Text(
                                      '11 steg',
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            // Ace: confirm after choosing value when not leaving start
                            else if (canPlayCard &&
                                selectedCard != null &&
                                selectedCard!.rank == 1 &&
                                selectedPiece != null &&
                                fields[selectedPiece!.fieldIndex].type != 'start' &&
                                selectedMoveValue != null)
                              ElevatedButton(
                                onPressed: _handlePlayCardButton,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
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
                            // Seven mode: confirm or cancel once all steps are allocated
                            else if (inSevenMode && remainingSevenSteps == 0)
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _handleConfirmSevenMoves,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Bekreft syver-trekk',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: _handleCancelSeven,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 5,
                                    ),
                                    child: const Text(
                                      'Avbryt',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )
                            // Standard "play card" button
                            else
                              Visibility(
                                visible: canPlayCard && !inSevenMode,
                                child: ElevatedButton(
                                  onPressed: _handlePlayCardButton,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
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
                            // "Pass turn" button if no moves
                            Visibility(
                              visible: isMyTurn && !canMove && !inSevenMode,
                              child: ElevatedButton(
                                onPressed: _handlePassButton,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
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
                        const SizedBox(width: 20),
                        // Draw pile and deck info
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (inSevenMode)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 14.0),
                                    child: Text(
                                      "$remainingSevenSteps steg igjen",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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
                              ],
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
                    // Player's hand (my cards)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (row) {
                        int startIdx = row * 2;
                        final hand = gameManager.handOf(myPlayerNumber);
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
                                              : (isPlayable ? hoverColor : Colors.white),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.orange
                                                : (isPlayable ? Colors.green : Colors.black26),
                                            width: isSelected ? 3 : (isPlayable ? 2.3 : 1.5),
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: Colors.orange,
                                                blurRadius: 7,
                                                offset: const Offset(0, 2),
                                              ),
                                            if (!isSelected && isPlayable)
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
              // Board and player boxes
              Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: getBoardRotation(myPlayerNumber),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Board border
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
                        // Fields
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
                            color = Colors.black;
                          } else if (f.type == 'goal' || f.type == 'start') {
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
                        // Seven-mode overlays: selected and valid targets
                        ...sevenSelectedTargets.map((idx) {
                          final fSel = fields[idx];
                          double overlaySize = baseFieldSize;
                          if (fSel.type == 'immunity') overlaySize *= immunityMultiplier;
                          if (fSel.type == 'start') overlaySize *= startMultiplier;
                          final posSel = Offset(
                            fSel.relPos.dx * boardSide,
                            fSel.relPos.dy * boardSide,
                          );
                          return Positioned(
                            left: posSel.dx - overlaySize / 2,
                            top: posSel.dy - overlaySize / 2,
                            child: Container(
                              width: overlaySize,
                              height: overlaySize,
                              decoration: BoxDecoration(
                                color: Colors.orange.withAlpha(120),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        }),
                        ...sevenValidTargets.map((idx) {
                          final fVal = fields[idx];
                          double overlaySize = baseFieldSize;
                          if (fVal.type == 'immunity') overlaySize *= immunityMultiplier;
                          if (fVal.type == 'start') overlaySize *= startMultiplier;
                          final posVal = Offset(
                            fVal.relPos.dx * boardSide,
                            fVal.relPos.dy * boardSide,
                          );
                          return Positioned(
                            left: posVal.dx - overlaySize / 2,
                            top: posVal.dy - overlaySize / 2,
                            child: GestureDetector(
                              onTap: () {
                                _handleSevenFieldTap(idx);
                              },
                              child: Container(
                                width: overlaySize,
                                height: overlaySize,
                                decoration: BoxDecoration(
                                  color: Colors.green.withAlpha(100),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        }),
                        // Pieces
                        ...gameManager.pieces.map((piece) {
                          final field = fields[piece.fieldIndex];
                          final pos = Offset(
                            field.relPos.dx * boardSide,
                            field.relPos.dy * boardSide,
                          );
                          final bool isMine = piece.player == myPlayerNumber;
                          final bool isSelected = selectedPiece == piece;
                          final bool canMovePiece = movablePieces.contains(piece);

                          // Outline color
                          Color outlineColor;
                          if (isMine && canMovePiece && isMyTurn) {
                            outlineColor =
                                isSelected ? Colors.orange : Colors.green;
                          } else if (!isMine) {
                            outlineColor = Colors.grey;
                          } else {
                            outlineColor = Colors.grey.shade300;
                          }

                          // Show skull if piece will be knocked out
                          bool showSkull = false;
                          if (targetedEnemyPiece != null &&
                              piece == targetedEnemyPiece) {
                            showSkull = true;
                          }
                          if (inSevenMode && sevenTargetedPieces.contains(piece)) {
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

                          // Make pieces tappable if they can move
                          if (inSevenMode && isMine && isMyTurn) {
                            pieceWidget = GestureDetector(
                              onTap: () => _handlePieceTap(piece),
                              child: pieceWidget,
                            );
                          } else if (!inSevenMode &&
                              isMine &&
                              canMovePiece &&
                              isMyTurn &&
                              !showSkull) {
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
                        // Center "DOG" box
                        Transform.rotate(
                          angle: -getBoardRotation(myPlayerNumber),
                          child: CenterBox(width: boardSide * 0.25),
                        ),
                      ],
                    ),
                  ),
                  // Player hand boxes around the board
                  Positioned(
                    bottom: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: PlayerHandBox(
                      player: boxOrder[0],
                      width: boxWidth,
                      isMe: true,
                      isCurrentPlayer: gameManager.currentPlayer == boxOrder[0],
                      hand: gameManager.handOf(boxOrder[0]),
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
                        hand: gameManager.handOf(boxOrder[1]),
                      ),
                    ),
                  ),
                  Positioned(
                    top: boxHeight * 0.2,
                    left: (boardSide - boxWidth) / 2,
                    child: Transform.rotate(
                      angle: 0,
                      child: PlayerHandBox(
                        player: boxOrder[2],
                        width: boxWidth,
                        isCurrentPlayer: gameManager.currentPlayer == boxOrder[2],
                        hand: gameManager.handOf(boxOrder[2]),
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
                        hand: gameManager.handOf(boxOrder[3]),
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
