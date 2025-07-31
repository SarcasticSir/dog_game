import 'models/piece.dart';
import 'models/field.dart';
import 'dog_card.dart';

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

  // Spill et kort – sjekker at det er riktig spiller og kort
  bool playCard(int player, DogCard card) {
    if (player != currentPlayer) return false;
    if (!playerHands[player - 1].contains(card)) return false;

    playerHands[player - 1].remove(card);
    discardPile.add(card);

    // Neste spiller
    currentPlayer = (currentPlayer % 4) + 1;
    return true;
  }

  // Returner gyldige kort på hånd for en spiller
  List<DogCard> handOf(int player) => playerHands[player - 1];

  // Returner alle brikker for en spiller
  List<DogPiece> piecesOf(int player) =>
      pieces.where((p) => p.player == player).toList();

  // Hent feltet til en brikke
  Field fieldOfPiece(DogPiece piece) => fields[piece.fieldIndex];

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
