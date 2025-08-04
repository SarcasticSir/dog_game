//import 'package:flutter/material.dart';
import 'package:dog_game/dog_card.dart';
import 'package:dog_game/models/piece.dart';
import 'package:dog_game/models/field.dart';

/// En enkel klasse for å representere et mulig trekk.
/// Et trekk består av en brikke og et kort som brukes på den brikken.

class Move {
  final DogPiece piece;
  final DogCard card;
  final int moveValue; // Kan være positiv eller negativ

  Move({required this.piece, required this.card, required this.moveValue});
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

  // Ikke mulig å flytte fra mål eller immunplass med spesialverdier (håndteres ellers)
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

  /// Spiller et kort og flytter en brikke
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
    // Hvis ingen startfelt er ledige, skjer ingenting (for enkelhetens skyld)
  }

  /// Oppdaterer currentPlayer til neste spiller.
  /// Denne metoden er nå offentlig, slik at du kan kalle den fra en "Pass turn"-knapp.
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


  /// Sjekker om en brikke kan flyttes med et bestemt kort.
  bool canPieceMove(DogPiece piece, DogCard card) {
    // Sjekker om brikken kan flytte fra startområdet med 1, 13 eller joker
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

    // Forenklet bevegelse: flytt fremover med kortets verdi
    int moveValue = card.rank ?? 0;
    if (card.rank == 4) {
        moveValue = -4; // Spesialtilfelle: flytt bakover
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

    // Sjekk om det nye feltet er opptatt av en egen brikke
    final occupyingPiece = pieces.firstWhere(
      (p) => p.fieldIndex == newFieldIndex,
      orElse: () => DogPiece(player: -1, fieldIndex: -1),
    );
    return occupyingPiece.player == -1 || occupyingPiece.player != piece.player;
  }

  /// Sjekker om en spiller har mulige trekk.
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

  /// Henter en liste over alle mulige trekk for en gitt spiller.
  /// Hvert trekk er representert av en [Move]-instans.
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
        // Standard
        int value = card.rank ?? 0;
        if (card.rank == 7) value = 7; // Evt. 7-logikk senere
        if (canPieceMoveWithValue(piece, card, value)) {
          possibleMoves.add(Move(piece: piece, card: card, moveValue: value));
        }
      }
    }
  }
  return possibleMoves;
}
}