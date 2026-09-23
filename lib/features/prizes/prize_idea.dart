import 'package:safini/core/translation/generated/l10n.dart';

/// Things kids most often save up for, as localized templates. A template only
/// prefills the editor; the parent can change the name and price before
/// anything is added.
///
/// Prices assume the task ideas' 10 to 20 coins a task, a few tasks a day: a
/// treat is a couple of days of chores, a bike or a pet is a month or more.
enum PrizeIdea {
  iceCream('ice-cream', '🍦', 40),
  book('new-book', '📚', 150),
  pizzaNight('pizza-night', '🍕', 200),
  cinema('cinema-trip', '🎬', 250),
  newToy('new-toy', '🧸', 300),
  backpack('new-backpack', '🎒', 600),
  lego('lego-set', '🧱', 800),
  videoGame('video-game', '🎮', 1000),
  bike('new-bike', '🚲', 2500),
  pet('pet', '🐶', 3000);

  const PrizeIdea(this.key, this.emoji, this.coins);

  /// Sent as `template_key`, so we can see which ideas parents actually use.
  final String key;
  final String emoji;
  final int coins;

  String title(S s) => switch (this) {
    PrizeIdea.iceCream => s.prizeIdeaIceCream,
    PrizeIdea.book => s.prizeIdeaBook,
    PrizeIdea.pizzaNight => s.prizeIdeaPizzaNight,
    PrizeIdea.cinema => s.prizeIdeaCinema,
    PrizeIdea.newToy => s.prizeIdeaNewToy,
    PrizeIdea.backpack => s.prizeIdeaBackpack,
    PrizeIdea.lego => s.prizeIdeaLego,
    PrizeIdea.videoGame => s.prizeIdeaVideoGame,
    PrizeIdea.bike => s.prizeIdeaBike,
    PrizeIdea.pet => s.prizeIdeaPet,
  };

  /// Ideas not yet in this child's store. Once a parent adds one it drops off
  /// the list, so the list shrinks as the store fills.
  static List<PrizeIdea> notIn(Iterable<String?> templateKeys) {
    final used = templateKeys.whereType<String>().toSet();
    return values.where((idea) => !used.contains(idea.key)).toList();
  }
}

/// The price step for a coin stepper: fine for treats, coarse for a bike.
int prizePriceStep(int coins) => coins < 200
    ? 10
    : coins < 1000
    ? 50
    : 100;

int nextPrizePrice(int coins) =>
    (coins + prizePriceStep(coins)).clamp(10, 100000);

/// Stepping down from 1000 lands on 950, not 900: the step is the one below.
int previousPrizePrice(int coins) =>
    (coins - prizePriceStep(coins - 1)).clamp(10, 100000);
