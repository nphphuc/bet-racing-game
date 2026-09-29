import 'dart:math';

import '../models/bet_model.dart';
import '../models/race_result_model.dart';
import 'interfaces/i_race_engine.dart';

class RaceEngineImpl implements IRaceEngine {
  final Random _random = Random();

  @override
  List<Duration> calculateDurations({
    required int racerCount,
    required int baseDurationSeconds,
  }) {
    int baseMs = baseDurationSeconds * 1000;
    return List.generate(racerCount, (index) {
      // Mỗi tay đua chênh lệch ngẫu nhiên từ -400ms đến +400ms so với base
      int variance = _random.nextInt(800) - 400;
      int durationMs = (baseMs + variance).clamp(1000, 30000);
      return Duration(milliseconds: durationMs);
    });
  }

  @override
  RaceResult calculateResult({
    required List<BetItem> bets,
    required int winnerId,
    required int currentBalance,
  }) {
    int totalBet = bets.fold(0, (sum, item) => sum + item.betAmount);
    int payout = 0;

    for (var b in bets) {
      if (b.racerId == winnerId) {
        payout += b.betAmount * 2; // Ví dụ cược trúng nhận thưởng x2
      }
    }

    int newBalance = currentBalance - totalBet + payout;

    return RaceResult(
      winnerRacerId: winnerId,
      totalBet: totalBet,
      totalPayout: payout,
      newBalance: newBalance,
      bets: bets,
    );
  }
}
