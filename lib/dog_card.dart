// lib/dog_card.dart

enum Suit { spades, hearts, diamonds, clubs, joker }

class DogCard {
  final Suit suit;
  final int? rank; // 1–13 (Ess-Konge), null for joker

  DogCard(this.suit, this.rank);

  @override
  String toString() {
    if (suit == Suit.joker) return 'Joker';
    const ranks = [
      '', 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'
    ];
    final suitSymbol = {
      Suit.spades: '♠',
      Suit.hearts: '♥',
      Suit.diamonds: '♦',
      Suit.clubs: '♣',
    }[suit];
    return '${ranks[rank!]}$suitSymbol';
  }
}

// Funksjon som lager dobbel kortstokk + jokere
List<DogCard> buildDogDeck() {
  List<DogCard> deck = [];
  for (var _ = 0; _ < 2; _++) {
    for (var suit in [Suit.spades, Suit.hearts, Suit.diamonds, Suit.clubs]) {
      for (var rank = 1; rank <= 13; rank++) {
        deck.add(DogCard(suit, rank));
      }
    }
  }
  for (var _ = 0; _ < 4; _++) {
    deck.add(DogCard(Suit.joker, null));
  }
  return deck;
}
