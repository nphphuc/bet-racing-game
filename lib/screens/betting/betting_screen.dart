import 'package:flutter/material.dart';

import '../../models/racer_model.dart';
import '../../models/bet_model.dart';
import '../../services/racer_repository_impl.dart';
import '../race/race_screen.dart';

class BettingScreen extends StatefulWidget {
  final String username;
  final int balance;

  const BettingScreen({
    super.key,
    required this.username,
    required this.balance,
  });

  @override
  State<BettingScreen> createState() => _BettingScreenState();
}

class _BettingScreenState extends State<BettingScreen> {
  final _racerRepo = RacerRepositoryImpl();
  late List<Racer> _racers;
  final List<TextEditingController> _betControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  int _baseDurationSeconds = 5; // Tùy chỉnh thời gian chạy (giây)

  @override
  void initState() {
    super.initState();
    _racers = _racerRepo.getRacers(); // Lấy đúng 3 đối tượng đua
  }

  @override
  void dispose() {
    for (final controller in _betControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startRace() {
    final bets = <BetItem>[];
    var total = 0;
    for (var i = 0; i < _racers.length; i++) {
      final value = _betControllers[i].text.trim();
      final amount = value.isEmpty ? 0 : int.tryParse(value);
      if (amount == null || amount < 0) {
        _showError('Tiền cược phải là số nguyên không âm.');
        return;
      }
      total += amount;
      if (amount > 0) {
        bets.add(BetItem(racerId: _racers[i].id, betAmount: amount));
      }
    }
    if (total == 0) {
      _showError('Hãy đặt cược ít nhất 1 Coin.');
      return;
    }
    if (total > widget.balance) {
      _showError('Tổng cược không được vượt quá số dư.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RaceScreen(
          racers: _racers,
          baseDurationSeconds: _baseDurationSeconds,
          bets: bets,
          currentBalance: widget.balance,
          username: widget.username,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đặt Cược (3 Làn Đua)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Số dư hiện có: ${widget.balance} Coin'),
            // Thanh Slider chỉnh thời gian đua tùy ý
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Thời gian đua: $_baseDurationSeconds giây"),
                Expanded(
                  child: Slider(
                    value: _baseDurationSeconds.toDouble(),
                    min: 3,
                    max: 15,
                    divisions: 12,
                    onChanged: (val) =>
                        setState(() => _baseDurationSeconds = val.toInt()),
                  ),
                ),
              ],
            ),
            const Divider(),
            // 3 ô nhập cược cố định
            Expanded(
              child: ListView.builder(
                itemCount: _racers.length,
                itemBuilder: (context, i) {
                  final racer = _racers[i];
                  return ListTile(
                    leading: Icon(racer.icon, color: racer.color),
                    title: Text(racer.name),
                    trailing: SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _betControllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "Số coin"),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _startRace,
              child: const Text("Bắt đầu cuộc đua"),
            ),
          ],
        ),
      ),
    );
  }
}
