import 'package:bet_racing_game/models/bet_model.dart';
import 'package:bet_racing_game/models/racer_model.dart';
import 'package:bet_racing_game/screens/betting/betting_screen.dart';
import 'package:bet_racing_game/screens/home/main_screen.dart';
import 'package:bet_racing_game/screens/race/race_screen.dart';
import 'package:bet_racing_game/screens/result/result_screen.dart';
import 'package:bet_racing_game/services/balance_repository.dart';
import 'package:bet_racing_game/services/race_engine_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryPreferences implements BalanceStorage {
  final values = <String, int>{};

  @override
  Future<int?> getInt(String key) async => values[key];

  @override
  Future<void> setInt(String key, int value) async {
    values[key] = value;
  }
}

class FailingBalanceRepository extends BalanceRepository {
  FailingBalanceRepository() : super(storage: MemoryPreferences());
  bool fail = true;

  @override
  Future<void> save(String username, int balance) async {
    if (fail) throw Exception('storage unavailable');
  }
}

void main() {
  final racers = [
    Racer(id: 1, name: 'Tay đua #1', color: Colors.red, icon: Icons.pets),
    Racer(id: 2, name: 'Tay đua #2', color: Colors.blue, icon: Icons.pets),
    Racer(id: 3, name: 'Tay đua #3', color: Colors.amber, icon: Icons.pets),
  ];
  final engine = RaceEngineImpl();

  test('tính thắng, thua và nhiều khoản cược theo x2', () {
    final win = engine.calculateResult(
      bets: [BetItem(racerId: 1, betAmount: 20)],
      winnerId: 1,
      currentBalance: 100,
    );
    expect(win.totalBet, 20);
    expect(win.totalPayout, 40);
    expect(win.newBalance, 120);

    final lose = engine.calculateResult(
      bets: [BetItem(racerId: 1, betAmount: 20)],
      winnerId: 2,
      currentBalance: 100,
    );
    expect(lose.totalPayout, 0);
    expect(lose.newBalance, 80);

    final mixed = engine.calculateResult(
      bets: [
        BetItem(racerId: 1, betAmount: 20),
        BetItem(racerId: 2, betAmount: 30),
      ],
      winnerId: 2,
      currentBalance: 100,
    );
    expect(mixed.totalBet, 50);
    expect(mixed.totalPayout, 60);
    expect(mixed.newBalance, 110);
    expect(mixed.bets.length, 2);
  });

  test('số dư được lưu riêng theo tài khoản', () async {
    final preferences = MemoryPreferences();
    final firstSession = BalanceRepository(storage: preferences);
    expect(await firstSession.load('admin'), 100);
    expect(await firstSession.load('player1'), 100);
    await firstSession.save('admin', 120);
    final nextSession = BalanceRepository(storage: preferences);
    expect(await nextSession.load('admin'), 120);
    expect(await nextSession.load('player1'), 100);
    await nextSession.save('admin', 80);
    final thirdSession = BalanceRepository(storage: preferences);
    expect(await thirdSession.load('admin'), 80);
    expect(await thirdSession.load('player1'), 100);
  });

  testWidgets('Betting từ chối cược trống, âm, chữ và vượt số dư', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: BettingScreen(username: 'admin', balance: 100)),
    );
    final start = find.text('Bắt đầu cuộc đua');
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Hãy đặt cược ít nhất 1 Coin.'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '-1');
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Tiền cược phải là số nguyên không âm.'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'abc');
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Tiền cược phải là số nguyên không âm.'), findsOneWidget);
    ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
        .clearSnackBars();
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '101');
    await tester.tap(start);
    await tester.pump();
    expect(find.text('Tổng cược không được vượt quá số dư.'), findsOneWidget);
    expect(find.byType(RaceScreen), findsNothing);
  });

  testWidgets('Betting chuyển đúng các khoản cược sang Race', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BettingScreen(username: 'admin', balance: 100)),
    );
    await tester.enterText(find.byType(TextField).at(0), '20');
    await tester.enterText(find.byType(TextField).at(1), '30');
    await tester.tap(find.text('Bắt đầu cuộc đua'));
    await tester.pumpAndSettle();
    final race = tester.widget<RaceScreen>(find.byType(RaceScreen));
    expect(race.username, 'admin');
    expect(race.currentBalance, 100);
    expect(race.bets.map((bet) => bet.betAmount), [20, 30]);
  });

  testWidgets('Result hiện bảng và Play Again nhận số dư mới', (tester) async {
    final preferences = MemoryPreferences();
    final result = engine.calculateResult(
      bets: [
        BetItem(racerId: 1, betAmount: 20),
        BetItem(racerId: 2, betAmount: 30),
      ],
      winnerId: 1,
      currentBalance: 100,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          result: result,
          racers: racers,
          username: 'admin',
          balanceRepository: BalanceRepository(storage: preferences),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('🏆 Người thắng: Tay đua #1'), findsOneWidget);
    expect(find.text('20 Coin'), findsOneWidget);
    expect(find.text('Win'), findsOneWidget);
    expect(find.text('Lose'), findsOneWidget);
    expect(find.text('Không cược'), findsOneWidget);
    expect(find.text('Số dư mới: 90 Coin'), findsOneWidget);
    expect(preferences.values['balance:admin'], 90);

    await tester.tap(find.text('Play Again'));
    await tester.pumpAndSettle();
    final betting = tester.widget<BettingScreen>(find.byType(BettingScreen));
    expect(betting.balance, 90);
    expect(betting.username, 'admin');
  });

  testWidgets('Result về Home với số dư mới', (tester) async {
    final result = engine.calculateResult(
      bets: [BetItem(racerId: 1, betAmount: 20)],
      winnerId: 2,
      currentBalance: 100,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          result: result,
          racers: racers,
          username: 'admin',
          balanceRepository: BalanceRepository(storage: MemoryPreferences()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();
    expect(find.text('Số dư tài khoản: 80 Coin'), findsOneWidget);
    expect(tester.widget<MainScreen>(find.byType(MainScreen)).balance, 80);
  });

  testWidgets('Result khóa điều hướng nếu lưu lỗi và cho thử lại', (
    tester,
  ) async {
    final store = FailingBalanceRepository();
    final result = engine.calculateResult(
      bets: [BetItem(racerId: 1, betAmount: 20)],
      winnerId: 1,
      currentBalance: 100,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: ResultScreen(
          result: result,
          racers: racers,
          username: 'admin',
          balanceRepository: store,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Không thể lưu số dư. Vui lòng thử lại.'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Play Again'),
          )
          .onPressed,
      isNull,
    );
    store.fail = false;
    await tester.tap(find.text('Thử lưu lại'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Play Again'),
          )
          .onPressed,
      isNotNull,
    );
  });
}
