// lib/game_manager.dart
import 'package:dog_game/dog_card.dart';
import 'package:dog_game/models/piece.dart';
import 'package:dog_game/models/field.dart';

class Move {
  final DogPiece piece;
  final DogCard card;
  final int moveValue;
  Move({required this.piece, required this.card, required this.moveValue});
}

/// Syver-trekk består av flere deltrekk.
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
  int currentPlayer = 1;   // Hvem sin tur (1–4)
  List<DogPiece> pieces = [];
  List<List<DogCard>> playerHands = [[], [], [], []];
  List<DogCard> deck = [];
  List<DogCard> discardPile = [];
  List<Field> fields = [];
  int round = 1;

  static const int cardsPerRoundBase = 6;

  GameManager({required this.fields}) {
    setupNewGame();
  }

  /// Antall kort per runde (6,5,4,3,2, og så på nytt).
  int getCardsToDeal() => cardsPerRoundBase - ((round - 1) % 5);

  /// Klargjør et helt nytt spill.
  void setupNewGame() {
    pieces.clear();
    // Plasser brikker i startfelt
    for (int p = 1; p <= 4; p++) {
      final starts = fields.asMap().entries
          .where((e) => e.value.type == 'start' && e.value.player == p)
          .map((e) => e.key);
      for (final idx in starts) {
        pieces.add(DogPiece(player: p, fieldIndex: idx));
      }
    }
    // Bygg kortstokk og del ut til første runde
    deck = buildDogDeck();
    deck.shuffle();
    discardPile = [];
    round = 1;
    playerHands = [[], [], [], []];
    dealNewRound();
  }

  /// Del ut kort, roter startspiller og øk runde.
  void dealNewRound() {
    final count = getCardsToDeal();
    if (deck.length < count * 4) {
      deck.addAll(discardPile);
      discardPile.clear();
      deck.shuffle();
    }
    for (int p = 0; p < 4; p++) {
      playerHands[p].clear();
    }
    for (int i = 0; i < count; i++) {
      for (int p = 0; p < 4; p++) {
        playerHands[p].add(deck.removeLast());
      }
    }
    currentPlayer = ((round - 1) % 4) + 1;
    round++;
  }

  /// Kan brikken flyttes moveValue steg? Tar hensyn til immunitet og egne brikker.
  bool canPieceMoveWithValue(DogPiece piece, DogCard card, int moveValue) {
    final field = fields[piece.fieldIndex];
    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final mainIdx = fields.asMap().entries
            .firstWhere((e) =>
                e.value.player == piece.player &&
                e.value.type == 'immunity')
            .key;
        return !pieces.any((p) => p.fieldIndex == mainIdx);
      }
      return false;
    }

    final boardSize = 64;
    final steps = moveValue.abs();
    final direction = moveValue >= 0 ? 1 : -1;
    for (int i = 1; i <= steps; i++) {
      int pos = (piece.fieldIndex + i * direction) % boardSize;
      if (pos < 0) pos += boardSize;
      final occupant = pieces.firstWhere(
          (p) => p.fieldIndex == pos,
          orElse: () => DogPiece(player: -1, fieldIndex: -1));
      if (i < steps) {
        // Kan ikke passere egen brikke
        if (occupant.player == piece.player && occupant.player != -1) return false;
        // Kan ikke passere immun
        if (occupant.player != -1 &&
            occupant.player != piece.player &&
            occupant.isImmune) {return false;
            }
      } else {
        // Landingsposisjon
        if (occupant.player == piece.player) return false;
        if (occupant.player != -1 && occupant.isImmune) return false;
      }
    }
    return true;
  }

  /// Kan dette kortet spilles på denne brikken?
  bool canPieceMove(DogPiece piece, DogCard card) {
    final field = fields[piece.fieldIndex];
    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final mainIdx = fields.asMap().entries
            .firstWhere((e) =>
                e.value.player == piece.player &&
                e.value.type == 'immunity')
            .key;
        return !pieces.any((p) => p.fieldIndex == mainIdx);
      }
      return false;
    }

    // Joker fungerer som alle kort unntatt 7-splitt
    List<int> options;
    if (card.suit == Suit.joker) {
      options = [-4, 4, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    } else if (card.rank == 1) {
      options = [1, 11];
    } else if (card.rank == 4) {
      options = [4, -4];
    } else if (card.rank == 7) {
      options = [1, 2, 3, 4, 5, 6, 7];
    } else {
      options = [card.rank!];
    }

    for (final v in options) {
      if (canPieceMoveWithValue(piece, card, v)) return true;
    }
    return false;
  }

  /// Finn alle mulige trekk for en spiller.
  List<Move> getPossibleMovesForPlayer(int player) {
    final result = <Move>[];
    for (final piece in piecesOf(player)) {
      for (final card in handOf(player)) {
        if (card.suit == Suit.joker) {
          for (final v in [-4, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]) {
            if (canPieceMoveWithValue(piece, card, v)) {
              result.add(Move(piece: piece, card: card, moveValue: v));
            }
          }
        } else if (card.rank == 1) {
          if (canPieceMoveWithValue(piece, card, 1)) {
            result.add(Move(piece: piece, card: card, moveValue: 1));
          }
          if (canPieceMoveWithValue(piece, card, 11)) {
            result.add(Move(piece: piece, card: card, moveValue: 11));
          }
        } else if (card.rank == 4) {
          if (canPieceMoveWithValue(piece, card, 4)) {
            result.add(Move(piece: piece, card: card, moveValue: 4));
          }
          if (canPieceMoveWithValue(piece, card, -4)) {
            result.add(Move(piece: piece, card: card, moveValue: -4));
          }
        } else if (card.rank == 7) {
          for (int i = 1; i <= 7; i++) {
            if (canPieceMoveWithValue(piece, card, i)) {
              result.add(Move(piece: piece, card: card, moveValue: i));
              break;
            }
          }
        } else {
          final v = card.rank ?? 0;
          if (v != 0 && canPieceMoveWithValue(piece, card, v)) {
            result.add(Move(piece: piece, card: card, moveValue: v));
          }
        }
      }
    }
    return result;
  }

  /// Flytter en brikke med et kort (ikke syver).
  bool playCard(int player, DogCard card, DogPiece piece, int moveValue) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;

    final field = fields[piece.fieldIndex];
    // Fra start
    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final mainIdx = fields.asMap().entries
            .firstWhere((e) =>
                e.value.player == player &&
                e.value.type == 'immunity')
            .key;
        if (pieces.any((p) => p.fieldIndex == mainIdx)) return false;
        piece.fieldIndex = mainIdx;
        piece.isImmune = true;
      } else {
        return false;
      }
    } else {
      final boardSize = 64;
      final steps = moveValue.abs();
      final direction = moveValue >= 0 ? 1 : -1;
      for (int i = 1; i <= steps; i++) {
        int pos = (piece.fieldIndex + i * direction) % boardSize;
        if (pos < 0) pos += boardSize;
        final occ = pieces.firstWhere(
          (p) => p.fieldIndex == pos,
          orElse: () => DogPiece(player: -1, fieldIndex: -1),
        );
        if (i < steps) {
          if (occ.player == player && occ.player != -1) return false;
          if (occ.player != -1 && occ.isImmune) return false;
        }
        if (i == steps) {
          if (occ.player == player) return false;
          if (occ.player != -1 && occ.isImmune) return false;
          if (occ.player != -1) _sendPieceBackToStart(occ);
        }
      }
      piece.fieldIndex = (piece.fieldIndex + moveValue) % boardSize;
      if (piece.fieldIndex < 0) piece.fieldIndex += boardSize;
      piece.isImmune = false;
    }
    playerHands[player - 1].remove(card);
    discardPile.add(card);
    passTurn();
    return true;
  }

  /// Utfører et syver-trekk (eller Joker som syver).
  bool playSevenCard(int player, DogCard card, List<SevenMoveStep> steps) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;
    if (card.rank != 7 && card.suit != Suit.joker) return false;
    final sum = steps.fold(0, (prev, s) => prev + s.steps.abs());
    if (sum != 7) return false;
    // Ingen steg med brikker i start
    for (final s in steps) {
      if (fields[s.piece.fieldIndex].type == 'start') return false;
    }
    // Simuler alle trekk
    final positions = Map<DogPiece, int>.fromEntries(
      pieces.map((p) => MapEntry(p, p.fieldIndex)),
    );
    for (final s in steps) {
      final piece = s.piece;
      int from = positions[piece]!;
      final dir = s.steps >= 0 ? 1 : -1;
      final num = s.steps.abs();
      final size = 64;
      for (int i = 1; i <= num; i++) {
        int pos = from + i * dir;
        pos %= size;
        if (pos < 0) pos += size;
        final occ = positions.entries.firstWhere(
          (e) => e.value == pos,
          orElse: () =>
              MapEntry(DogPiece(player: -1, fieldIndex: -1), -1),
        ).key;
        if (i < num) {
          if (occ.player == player && occ.player != -1) return false;
          if (occ.player != -1 && occ.isImmune) return false;
        } else {
          if (occ.player == player) return false;
          if (occ.player != -1 && occ.isImmune) return false;
        }
      }
      int toIdx = from + s.steps;
      toIdx %= size;
      if (toIdx < 0) toIdx += size;
      positions[piece] = toIdx;
    }

    // Utfør trekk
    final knocked = <DogPiece>{};
    for (final s in steps) {
      final piece = s.piece;
      int from = piece.fieldIndex;
      final dir = s.steps >= 0 ? 1 : -1;
      final num = s.steps.abs();
      final size = 64;
      for (int i = 1; i <= num; i++) {
        int pos = from + i * dir;
        pos %= size;
        if (pos < 0) pos += size;
        final occ = pieces.firstWhere(
          (p) => p.fieldIndex == pos,
          orElse: () => DogPiece(player: -1, fieldIndex: -1),
        );
        if (occ.player != -1 && !occ.isImmune) {
          final partner = ((player + 1) % 4) + 1;
          if (occ.player != player && occ.player != partner) {
            knocked.add(occ);
          }
        }
      }
      piece.fieldIndex = positions[piece]!;
      piece.isImmune = false;
    }
    for (final p in knocked) {
      _sendPieceBackToStart(p);
    }
    playerHands[player - 1].remove(card);
    discardPile.add(card);
    passTurn();
    return true;
  }

  /// Send en brikke hjem til første ledige startfelt.
  void _sendPieceBackToStart(DogPiece piece) {
    final starts = fields.asMap().entries
        .where((e) => e.value.type == 'start' && e.value.player == piece.player)
        .map((e) => e.key)
        .toList();
    for (final idx in starts) {
      if (!pieces.any((p) => p.fieldIndex == idx)) {
        piece.fieldIndex = idx;
        piece.isImmune = false;
        return;
      }
    }
  }

  // Hjelpefunksjoner (definert kun én gang)
  List<DogCard> handOf(int player) => playerHands[player - 1];
  List<DogPiece> piecesOf(int player) =>
      pieces.where((p) => p.player == player).toList();
  Field fieldOfPiece(DogPiece piece) => fields[piece.fieldIndex];
  bool isRoundOver() => playerHands.every((h) => h.isEmpty);

  /// Sett turen til neste spiller
  void passTurn() {
    currentPlayer = (currentPlayer % 4) + 1;
  }
}
