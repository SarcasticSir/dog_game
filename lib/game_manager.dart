import 'models/piece.dart';
import 'models/field.dart';
import 'dog_card.dart';

class GameManager {
  // TODO: I et nettverksspill vil denne tilstanden bli synkronisert fra en sanntidsdatabase (f.eks. Supabase).
  //  Spilltilstanden (steg, kort, brikker) vil ikke lagres lokalt, men leses fra databasen.
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

  // Spill et kort – sjekker at det er riktig spiller og kort
  bool playCard(int player, DogCard card, DogPiece piece) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;

    // Sjekker om trekket er gyldig før vi utfører det
    List<int> validMoves = getValidMoves(card, piece);
    if (validMoves.isEmpty) {
      return false;
    }

    movePiece(piece, validMoves.first);
    
    playerHands[player - 1].remove(card);
    discardPile.add(card);

    _nextPlayer();
    return true;
  }
  
  // Bytt til neste spiller.
  void _nextPlayer() {
    if (isRoundOver()) {
      dealNewRound();
    } else {
      currentPlayer = (currentPlayer % 4) + 1;
    }
  }

  // En spiller passer turen sin
  bool passTurn() {
    if (getPossibleMovesForPlayer(currentPlayer).isEmpty) {
      // Hvis spilleren ikke har noen mulige trekk, kast alle kortene
      // og bytt til neste spiller.
      discardPile.addAll(playerHands[currentPlayer - 1]);
      playerHands[currentPlayer - 1].clear();
      _nextPlayer();
      print("Spiller $currentPlayer hadde ingen trekk og har foldet.");
      return true;
    }
    print("Spiller $currentPlayer har gyldige trekk og kan ikke folde.");
    return false;
  }

  // Sjekker om spilleren har noen gyldige trekk overhodet
  List<Map<String, dynamic>> getPossibleMovesForPlayer(int player) {
    List<Map<String, dynamic>> possibleMoves = [];
    
    for (var card in playerHands[player - 1]) {
      for (var piece in pieces.where((p) => p.player == player)) {
        if (getValidMoves(card, piece).isNotEmpty) {
          possibleMoves.add({'card': card, 'piece': piece});
        }
      }
    }
    return possibleMoves;
  }

  // Returner gyldige trekk for en brikke med et spesifikt kort
  List<int> getValidMoves(DogCard card, DogPiece piece) {
    List<int> validMoves = [];

    // Hjelpemetode for å finne ut om en brikke er i startområdet.
    bool isInStartArea() {
      final field = fields[piece.fieldIndex];
      return field.type == 'start' && field.player == piece.player;
    }
    
    // Håndter spesialkort for å komme ut fra startområdet (Ess, Konge, Joker).
    if (isInStartArea()) {
      if (card.rank == 1 || card.rank == 13 || card.suit == Suit.joker) {
        final int firstMainFieldIndex = _getFirstMainField(piece.player);
        if (firstMainFieldIndex != -1) {
          validMoves.add(firstMainFieldIndex);
        }
      }
      return validMoves;
    }
    
    // Foreløpig enkel logikk: flytt antall steg fra kortet.
    // Vi ser bort fra spesialkort og kollisjoner for nå.
    if (card.rank != null) {
      int newIndex = piece.fieldIndex + card.rank!;
      // Sjekk for brettgrenser
      if (newIndex < fields.length) {
        validMoves.add(newIndex);
      }
    }
    // TODO: Legg til spesialkort (ess, 7, joker) og andre regler.

    return validMoves;
  }

  // Utfør et trekk – oppdaterer brikkens posisjon
  void movePiece(DogPiece piece, int newIndex) {
    // TODO: Legg til kollisjons-logikk her for å sende brikker tilbake til start.
    // Her må vi også sjekke om brikken som flyttes er i ferd med å lande på en annen brikke.
    piece.fieldIndex = newIndex;
  }

  // Hjelpemetode for å finne det første feltet på hovedbrettet for en spiller
  int _getFirstMainField(int player) {
    switch (player) {
      case 1:
        return 0; // Spiller 1s første felt
      case 2:
        return 16; // Spiller 2s første felt
      case 3:
        return 32; // Spiller 3s første felt
      case 4:
        return 48; // Spiller 4s første felt
      default:
        return -1;
    }
  }

  // Enkel sjekk for om runden er over
  bool isRoundOver() => playerHands.every((h) => h.isEmpty);

  // Del ut nye kort til ny runde (hvis ønsket)
  void dealNewRound() {
    if (deck.length < cardsPerPlayer * 4) {
      // Bland inn kastede kort
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
}
