import 'package:bet_racing_game/screens/home/main_screen.dart';
import 'package:bet_racing_game/screens/instruction/how_to_play_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Instruction screen displays the game rules', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HowToPlayScreen()));

    expect(find.text('Hướng Dẫn Chơi'), findsOneWidget);
    expect(find.textContaining('100 coin'), findsOneWidget);
    expect(find.textContaining('3 tay đua'), findsOneWidget);
    expect(find.textContaining('gấp đôi'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.textContaining('3s - 15s'), findsNothing);
  });

  testWidgets('Main menu opens the instruction screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainScreen(username: 'admin', balance: 100)),
    );

    expect(find.text('Hướng Dẫn Chơi (How to play)'), findsOneWidget);
    await tester.tap(find.text('Hướng Dẫn Chơi (How to play)'));
    await tester.pumpAndSettle();

    expect(find.byType(HowToPlayScreen), findsOneWidget);
    expect(find.text('Hướng Dẫn Chơi'), findsOneWidget);
  });
}
