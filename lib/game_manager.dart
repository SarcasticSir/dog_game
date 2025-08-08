import '../dog_card.dart';
import '../models/piece.dart';
import '../models/field.dart';

class Move {
  final DogPiece piece;
  final DogCard card;
  final int moveValue; // Kan være positiv eller negativ

  Move({required this.piece, required this.card, required this.moveValue});
}

class SevenMoveStep {
  final DogPiece piece;
  final int fromIndex;
  final int toIndex;
  final int steps;
  SevenMoveStep({
    required this.piece,
    required this.fromIndex,
    required this.toIndex,
    required this.steps,
  });
}

class GameManager {
  int currentPlayer = 1; // 1–4
  List<DogPiece> pieces = [];
  List<List<DogCard>> playerHands = [[], [], [], []];
  List<DogCard> deck = [];
  List<DogCard> discardPile = [];
  List<Field> fields = [];
  int round = 1;

  GameManager({required this.fields}) {
    setupNewGame();
  }

  int getCardsToDeal() {
    return 6 - ((round - 1) % 5);
  }

  void setupNewGame() {
    // Sett ut brikker i start
    pieces = [];
    for (int p = 1; p <= 4; p++) {
      final playerStartIndices = fields.asMap().entries
          .where((entry) =>
              entry.value.type == 'start' && entry.value.player == p)
          .map((entry) => entry.key)
          .toList();
      for (final idx in playerStartIndices) {
        pieces.add(DogPiece(player: p, fieldIndex: idx));
      }
    }
    deck = buildDogDeck();
    deck.shuffle();
    playerHands = [[], [], [], []];
    discardPile = [];
    round = 1;
    dealNewRound();
  }

  void dealNewRound() {
    final int cardsToDeal = getCardsToDeal();
    if (deck.length < cardsToDeal * 4) {
      deck.addAll(discardPile);
      discardPile.clear();
      deck.shuffle();
    }
    for (int p = 0; p < 4; p++) {
      playerHands[p].clear();
    }
    for (int i = 0; i < cardsToDeal; i++) {
      for (int p = 0; p < 4; p++) {
        playerHands[p].add(deck.removeLast());
      }
    }
    currentPlayer = ((round - 1) % 4) + 1;
    round++;
  }

  bool canPieceMoveWithValue(DogPiece piece, DogCard card, int moveValue) {
    final field = fields[piece.fieldIndex];

    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) =>
                entry.value.player == piece.player &&
                entry.value.type == 'immunity')
            .key;
        return !pieces.any((p) => p.fieldIndex == boardMainFieldIndex);
      }
      return false;
    }

    int boardSize = 64;
    int direction = moveValue >= 0 ? 1 : -1;
    int steps = moveValue.abs();
    int fromIndex = piece.fieldIndex;
    for (int i = 1; i <= steps; i++) {
      int pos = (fromIndex + direction * i) % boardSize;
      if (pos < 0) pos += boardSize;
      final occupier = pieces.firstWhere(
        (p) => p.fieldIndex == pos,
        orElse: () => DogPiece(player: -1, fieldIndex: -1),
      );
      if (i < steps) {
        if (occupier.player == piece.player && occupier.player != -1) {
          return false;
        }
        if (occupier.player != -1 &&
            occupier.player != piece.player &&
            occupier.isImmune) {
          return false;
        }
      }
      if (i == steps) {
        if (occupier.player == piece.player) {
          return false;
        }
        if (occupier.player != -1 && occupier.isImmune) {
          return false;
        }
      }
    }
    return true;
  }

  bool canPieceMove(DogPiece piece, DogCard card) {
    final field = fields[piece.fieldIndex];

    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) =>
                entry.value.player == piece.player &&
                entry.value.type == 'immunity')
            .key;
        return !pieces.any((p) => p.fieldIndex == boardMainFieldIndex);
      }
      return false;
    }

    List<int> possibleMoves = [];
    if (card.suit == Suit.joker) {
      possibleMoves = [4, -4, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    } else if (card.rank == 1) {
      possibleMoves = [1, 11];
    } else if (card.rank == 4) {
      possibleMoves = [4, -4];
    } else if (card.rank == 7) {
      possibleMoves = [1, 2, 3, 4, 5, 6, 7];
    } else {
      if (card.rank != null) {
        possibleMoves = [card.rank!];
      }
    }
    for (final mv in possibleMoves) {
      if (canPieceMoveWithValue(piece, card, mv)) return true;
    }
    return false;
  }

  bool hasPossibleMoves(int player) {
    final playerPieces = piecesOf(player);
    final playerHand = handOf(player);
    for (final piece in playerPieces) {
      for (final card in playerHand) {
        if (canPieceMove(piece, card)) {
          return true;
        }
      }
    }
    return false;
  }

  List<Move> getPossibleMovesForPlayer(int player) {
    final List<Move> possibleMoves = [];
    final playerPieces = piecesOf(player);
    final playerHand = handOf(player);

    for (final piece in playerPieces) {
      for (final card in playerHand) {
        if (card.suit == Suit.joker) {
          final values = [
            4,
            -4,
            1,
            2,
            3,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13
          ];
          for (final v in values) {
            if (canPieceMoveWithValue(piece, card, v)) {
              possibleMoves
                  .add(Move(piece: piece, card: card, moveValue: v));
            }
          }
        } else if (card.rank == 1) {
          if (canPieceMoveWithValue(piece, card, 1)) {
            possibleMoves
                .add(Move(piece: piece, card: card, moveValue: 1));
          }
          if (canPieceMoveWithValue(piece, card, 11)) {
            possibleMoves
                .add(Move(piece: piece, card: card, moveValue: 11));
          }
        } else if (card.rank == 4) {
          if (canPieceMoveWithValue(piece, card, 4)) {
            possibleMoves
                .add(Move(piece: piece, card: card, moveValue: 4));
          }
          if (canPieceMoveWithValue(piece, card, -4)) {
            possibleMoves
                .add(Move(piece: piece, card: card, moveValue: -4));
          }
        } else if (card.rank == 7) {
          bool canSeven = false;
          for (int i = 1; i <= 7; i++) {
            if (canPieceMoveWithValue(piece, card, i)) {
              canSeven = true;
              break;
            }
          }
          if (canSeven) {
            possibleMoves.add(
                Move(piece: piece, card: card, moveValue: 7));
          }
        } else {
          final int value = card.rank ?? 0;
          if (value != 0 &&
              canPieceMoveWithValue(piece, card, value)) {
            possibleMoves
                .add(Move(piece: piece, card: card, moveValue: value));
          }
        }
      }
    }
    return possibleMoves;
  }

  List<DogCard> handOf(int player) => playerHands[player - 1];
  List<DogPiece> piecesOf(int player) =>
      pieces.where((p) => p.player == player).toList();
  Field fieldOfPiece(DogPiece piece) => fields[piece.fieldIndex];

  bool playCard(int player, DogCard card, DogPiece piece, int moveValue) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;

    final field = fields[piece.fieldIndex];

    // From start
    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) =>
                entry.value.player == player &&
                entry.value.type == 'immunity')
            .key;
        if (pieces.any((p) => p.fieldIndex == boardMainFieldIndex)) {
          return false;
        }
        piece.fieldIndex = boardMainFieldIndex;
        piece.isImmune = true;
      } else {
        return false;
      }
    } else {
      int boardSize = 64;
      int direction = moveValue >= 0 ? 1 : -1;
      int steps = moveValue.abs();
      int fromIndex = piece.fieldIndex;
      for (int i = 1; i <= steps; i++) {
        int pos = (fromIndex + direction * i) % boardSize;
        if (pos < 0) pos += boardSize;
        final occupier = pieces.firstWhere(
          (p) => p.fieldIndex == pos,
          orElse: () => DogPiece(player: -1, fieldIndex: -1),
        );
        if (i < steps) {
          if (occupier.player == player && occupier.player != -1) {
            return false;
          }
          if (occupier.player != -1 &&
              occupier.player != player &&
              occupier.isImmune) {
            return false;
          }
        }
        if (i == steps) {
          if (occupier.player == player) {
            return false;
          }
          if (occupier.player != -1 && occupier.isImmune) {
            return false;
          }
          if (occupier.player != -1) {
            _sendPieceBackToStart(occupier);
          }
        }
      }
      piece.fieldIndex = (piece.fieldIndex + moveValue) % boardSize;
      if (piece.fieldIndex < 0) piece.fieldIndex += boardSize;
      piece.isImmune = false;
    }

    playerHands[player - 1].remove(card);
    discardPile.add(card);
    currentPlayer = (currentPlayer % 4) + 1;
    return true;
  }

  bool playSevenCard(int player, DogCard card, List<SevenMoveStep> steps) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;
    if (card.rank != 7 && card.suit != Suit.joker) return false;

    int sum = steps.fold(0, (prev, s) => prev + s.steps.abs());
    if (sum != 7) return false;
    // Cannot leave start with a seven card
    for (final step in steps) {
      if (fields[step.piece.fieldIndex].type == 'start') {
        return false;
      }
    }
    final Map<DogPiece, int> positions = {
      for (final p in pieces) p: p.fieldIndex
    };
    for (final step in steps) {
      final DogPiece piece = step.piece;
      int from = positions[piece]!;
      int boardSize = 64;
      int direction = step.steps >= 0 ? 1 : -1;
      int stepsCount = step.steps.abs();
      for (int i = 1; i <= stepsCount; i++) {
        int pos = (from + direction * i) % boardSize;
        if (pos < 0) pos += boardSize;
        final occupantEntry = positions.entries.firstWhere(
          (e) => e.value == pos,
          orElse: () => MapEntry(DogPiece(player: -1, fieldIndex: -1), -1),
        );
        final occupant = occupantEntry.key;
        if (i < stepsCount) {
          if (occupant.player == player && occupant.player != -1) {
            return false;
          }
          if (occupant.player != -1 && occupant.isImmune) {
            return false;
          }
        }
        if (i == stepsCount) {
          if (occupant.player == player) {
            return false;
          }
          if (occupant.player != -1 && occupant.isImmune) {
            return false;
          }
        }
      }
      int toIdx = from + step.steps;
      toIdx %= boardSize;
      if (toIdx < 0) toIdx += boardSize;
      positions[piece] = toIdx;
    }

    final Set<DogPiece> toSendHome = {};
    for (final step in steps) {
      final DogPiece piece = step.piece;
      int from = piece.fieldIndex;
      int boardSize = 64;
      int direction = step.steps >= 0 ? 1 : -1;
      int stepsCount = step.steps.abs();
      for (int i = 1; i <= stepsCount; i++) {
        int pos = (from + direction * i) % boardSize;
        if (pos < 0) pos += boardSize;
        final occupant = pieces.firstWhere(
          (p) => p.fieldIndex == pos,
          orElse: () => DogPiece(player: -1, fieldIndex: -1),
        );
        if (occupant.player != -1 && !occupant.isImmune) {
          final partner = ((player + 1) % 4) + 1;
          if (occupant.player != player && occupant.player != partner) {
            toSendHome.add(occupant);
          }
        }
      }
      piece.fieldIndex = positions[piece]!;
      piece.isImmune = false;
    }
    for (final p in toSendHome) {
      _sendPieceBackToStart(p);
    }
    playerHands[player - 1].remove(card);
    discardPile.add(card);
    currentPlayer = (currentPlayer % 4) + 1;
    return true;
  }

  void _sendPieceBackToStart(DogPiece piece) {
    final playerStartIndices = fields.asMap().entries
        .where((entry) =>
            entry.value.type == 'start' && entry.value.player == piece.player)
        .map((entry) => entry.key)
        .toList();
    for (final idx in playerStartIndices) {
      if (!pieces.any((p) => p.fieldIndex == idx)) {
        piece.fieldIndex = idx;
        piece.isImmune = false;
        return;
      }
    }
  }

  List<DogCard> handOf(int player) => playerHands[player - 1];
  List<DogPiece> piecesOf(int player) =>
      pieces.where((p) => p.player == player).toList();
  Field fieldOfPiece(DogPiece piece) => fields[piece.fieldIndex];

  /// Added method (missing earlier): advances the turn to the next player.
  void passTurn() {
    currentPlayer = (currentPlayer % 4) + 1;
  }
}
