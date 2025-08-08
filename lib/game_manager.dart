//lib\game_manager.dart


import 'package:dog_game/dog_card.dart';
import 'package:dog_game/models/piece.dart';
import 'package:dog_game/models/field.dart';

class Move {
  final DogPiece piece;
  final DogCard card;
  final int moveValue; // Kan være positiv eller negativ

  Move({required this.piece, required this.card, required this.moveValue});
}

/// Ny klasse: Et syver-trekk består av flere deltrekk (eks: 4 steg med en brikke, 3 med en annen)
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
  int currentPlayer = 1; // 1–4, hvem sin tur
  List<DogPiece> pieces = [];
  List<List<DogCard>> playerHands = [[], [], [], []]; // 0=spiller1
  List<DogCard> deck = [];
  List<DogCard> discardPile = [];
  List<Field> fields = [];
  int round = 1;

  static const int cardsPerPlayer = 6;

  GameManager({required this.fields}) {
    setupNewGame();
  }

  void setupNewGame() {
    // Sett ut brikker i startområdene
    pieces = [];
    for (int p = 1; p <= 4; p++) {
      final playerStartIndices = fields.asMap().entries
          .where((entry) => entry.value.type == 'start' && entry.value.player == p)
          .map((entry) => entry.key)
          .toList();
      for (final idx in playerStartIndices) {
        pieces.add(DogPiece(player: p, fieldIndex: idx));
      }
    }
    // Lag og del ut kort
    deck = buildDogDeck();
    deck.shuffle();
    playerHands = [[], [], [], []];
    for (int i = 0; i < cardsPerPlayer; i++) {
      for (int p = 0; p < 4; p++) {
        playerHands[p].add(deck.removeLast());
      }
    }
    discardPile = [];
    currentPlayer = 1;
    round = 1;
  }

  /// Standard flytt sjekk for ett enkelt steg
  bool canPieceMoveWithValue(DogPiece piece, DogCard card, int moveValue) {
    final field = fields[piece.fieldIndex];

    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) => entry.value.player == piece.player && entry.value.type == 'immunity')
            .key;
        // Sjekk om startfeltet er ledig
        return !pieces.any((p) => p.fieldIndex == boardMainFieldIndex);
      }
      return false;
    }

    int boardSize = 64;
    int newFieldIndex = (piece.fieldIndex + moveValue);
    if (newFieldIndex >= boardSize) {
      newFieldIndex = newFieldIndex % boardSize;
    } else if (newFieldIndex < 0) {
      newFieldIndex = boardSize + newFieldIndex;
    }

    final occupyingPiece = pieces.firstWhere(
      (p) => p.fieldIndex == newFieldIndex,
      orElse: () => DogPiece(player: -1, fieldIndex: -1),
    );
    return occupyingPiece.player == -1 || occupyingPiece.player != piece.player;
  }
  /// Spiller et kort og flytter en brikke – STANDARD (ikke syver)
  /// Returnerer true ved vellykket trekk, false ved ugyldig trekk
  bool playCard(int player, DogCard card, DogPiece piece, int moveValue) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;

    final field = fields[piece.fieldIndex];

    // Sjekker om brikken skal flyttes fra startområdet
    if (field.type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) => entry.value.player == player && entry.value.type == 'immunity')
            .key;
        if (!pieces.any((p) => p.fieldIndex == boardMainFieldIndex)) {
          piece.fieldIndex = boardMainFieldIndex;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      int boardSize = 64;
      int newFieldIndex = (piece.fieldIndex + moveValue);
      if (newFieldIndex >= boardSize) {
        newFieldIndex = newFieldIndex % boardSize;
      } else if (newFieldIndex < 0) {
        newFieldIndex = boardSize + newFieldIndex;
      }

      // Sjekk om det nye feltet er opptatt
      final occupyingPiece = pieces.firstWhere(
        (p) => p.fieldIndex == newFieldIndex,
        orElse: () => DogPiece(player: -1, fieldIndex: -1),
      );
      if (occupyingPiece.player != -1) {
        if (occupyingPiece.player == player) {
          // Kan ikke lande på egen brikke
          return false;
        } else {
          _sendPieceBackToStart(occupyingPiece);
        }
      }

      // Flytt brikken
      piece.fieldIndex = newFieldIndex;
    }

    // Fjern kortet og bytt tur
    playerHands[player - 1].remove(card);
    discardPile.add(card);
    passTurn();
    return true;
  }

  /// Ny! Utfører et "syver-trekk", med liste av steg
  /// Returnerer true ved suksess, false ved ugyldig trekk
  bool playSevenCard(int player, DogCard card, List<SevenMoveStep> steps) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;
    if (card.rank != 7) return false;
    int sum = steps.fold(0, (prev, s) => prev + s.steps.abs());
    if (sum != 7) return false;

    // Brukes for å holde styr på midlertidig board-tilstand under utførelse
    final usedPieces = <DogPiece, int>{};

    // Valider alle steg først: (må ikke lande på egen brikke, ikke gå over mål osv.)
    for (final step in steps) {
      // Finn startposisjon for denne brikken
      int fromIdx = usedPieces[step.piece] ?? step.piece.fieldIndex;
      int toIdx = fromIdx + step.steps;

      // Board wrap
      if (toIdx >= 64) toIdx = toIdx % 64;
      if (toIdx < 0) toIdx = 64 + toIdx;

      // Kan ikke lande på egen brikke
      final occupying = pieces.firstWhere(
        (p) => p.fieldIndex == toIdx,
        orElse: () => DogPiece(player: -1, fieldIndex: -1),
      );
      if (occupying.player == player) return false;

      // Oppdater for neste steg med samme brikke
      usedPieces[step.piece] = toIdx;
    }

    // Utfør stegene, slå ut fiender
    for (final step in steps) {
      int fromIdx = step.piece.fieldIndex;
      int toIdx = fromIdx + step.steps;
      if (toIdx >= 64) toIdx = toIdx % 64;
      if (toIdx < 0) toIdx = 64 + toIdx;

      final occupying = pieces.firstWhere(
        (p) => p.fieldIndex == toIdx,
        orElse: () => DogPiece(player: -1, fieldIndex: -1),
      );
      if (occupying.player != -1 && occupying.player != player) {
        _sendPieceBackToStart(occupying);
      }
      step.piece.fieldIndex = toIdx;
    }

    // Fjern kortet og bytt tur
    playerHands[player - 1].remove(card);
    discardPile.add(card);
    passTurn();
    return true;
  }

  // Sender en brikke tilbake til et ledig startfelt
  void _sendPieceBackToStart(DogPiece piece) {
    final playerStartIndices = fields.asMap().entries
        .where((entry) => entry.value.type == 'start' && entry.value.player == piece.player)
        .map((entry) => entry.key)
        .toList();

    // Finn første ledige startfelt
    for (final startIdx in playerStartIndices) {
      if (!pieces.any((p) => p.fieldIndex == startIdx)) {
        piece.fieldIndex = startIdx;
        return;
      }
    }
    // Hvis ingen startfelt er ledige, skjer ingenting
  }

  void passTurn() {
    currentPlayer = (currentPlayer % 4) + 1;
  }

  void dealNewRound() {
    if (deck.length < cardsPerPlayer * 4) {
      deck.addAll(discardPile);
      discardPile.clear();
      deck.shuffle();
    }
    for (int p = 0; p < 4; p++) {
      playerHands[p].clear();
    }
    for (int i = 0; i < cardsPerPlayer; i++) {
      for (int p = 0; p < 4; p++) {
        playerHands[p].add(deck.removeLast());
      }
    }
    round++;
    currentPlayer = 1;
  }

  List<DogCard> handOf(int player) => playerHands[player - 1];
  List<DogPiece> piecesOf(int player) =>
      pieces.where((p) => p.player == player).toList();
  Field fieldOfPiece(DogPiece piece) => fields[piece.fieldIndex];
  bool isRoundOver() => playerHands.every((h) => h.isEmpty);

  bool canPieceMove(DogPiece piece, DogCard card) {
    if (fields[piece.fieldIndex].type == 'start') {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int boardMainFieldIndex = fields.asMap().entries
            .firstWhere((entry) => entry.value.player == piece.player && entry.value.type == 'immunity')
            .key;
        // Sjekk om startfeltet er ledig
        return !pieces.any((p) => p.fieldIndex == boardMainFieldIndex);
      }
      return false;
    }

    int moveValue = card.rank ?? 0;
if (card.rank == 4) {
  moveValue = -4;
} else if (card.rank == 7) {
  moveValue = 7;
}


    final int boardSize = 64;
    int newFieldIndex = (piece.fieldIndex + moveValue);
    if (newFieldIndex >= boardSize) {
      newFieldIndex = newFieldIndex % boardSize;
    } else if (newFieldIndex < 0) {
      newFieldIndex = boardSize + newFieldIndex;
    }

    final occupyingPiece = pieces.firstWhere(
      (p) => p.fieldIndex == newFieldIndex,
      orElse: () => DogPiece(player: -1, fieldIndex: -1),
    );
    return occupyingPiece.player == -1 || occupyingPiece.player != piece.player;
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
        if (card.rank == 4) {
          // Kan flytte 4 fremover
          if (canPieceMoveWithValue(piece, card, 4)) {
            possibleMoves.add(Move(piece: piece, card: card, moveValue: 4));
          }
          // Kan flytte 4 bakover
          if (canPieceMoveWithValue(piece, card, -4)) {
            possibleMoves.add(Move(piece: piece, card: card, moveValue: -4));
          }
        } else {
          int value = card.rank ?? 0;
          if (card.rank == 7) value = 7; // NB: syver-variant (må håndteres med playSevenCard)
          if (canPieceMoveWithValue(piece, card, value)) {
            possibleMoves.add(Move(piece: piece, card: card, moveValue: value));
          }
        }
      }
    }
    return possibleMoves;
  }
}
