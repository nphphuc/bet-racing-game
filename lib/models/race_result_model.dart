import 'bet_model.dart';

class RaceResult {
  final int winnerRacerId;
  final int totalBet;
  final int totalPayout;
  final int newBalance;
  final List<BetItem> bets;

  RaceResult({
    required this.winnerRacerId,
    required this.totalBet,
    required this.totalPayout,
    required this.newBalance,
    required List<BetItem> bets,
  }) : bets = List.unmodifiable(bets);
}
