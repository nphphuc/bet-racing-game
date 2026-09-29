import 'package:flutter/material.dart';

import '../../models/racer_model.dart';
import '../../models/bet_model.dart';
import '../../services/race_engine_impl.dart';
import '../result/result_screen.dart';

class RaceScreen extends StatefulWidget {
  final List<Racer> racers;
  final int baseDurationSeconds;
  final List<BetItem> bets;
  final int currentBalance;
  final String username;

  const RaceScreen({
    super.key,
    required this.racers,
    required this.baseDurationSeconds,
    required this.bets,
    required this.currentBalance,
    required this.username,
  });

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> {
  final _engine = RaceEngineImpl();
  late List<Duration> _durations;
  bool _isRacing = false;
  int? _winnerId;

  @override
  void initState() {
    super.initState();
    // Tính toán thời gian ngẫu nhiên dựa trên baseDuration do người chơi chọn
    _durations = _engine.calculateDurations(
      racerCount: widget.racers.length,
      baseDurationSeconds: widget.baseDurationSeconds,
    );
  }

  void _startRace() {
    setState(() => _isRacing = true);
  }

  void _onFinish(int racerId) {
    if (_winnerId == null) {
      _winnerId = racerId;
      final result = _engine.calculateResult(
        bets: widget.bets,
        winnerId: racerId,
        currentBalance: widget.currentBalance,
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: result,
              racers: widget.racers,
              username: widget.username,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text("Đường Đua 3 Làn")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.racers.length,
              itemBuilder: (context, i) {
                final racer = widget.racers[i];
                return Container(
                  height: 65,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.grey.shade200,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: _durations[i],
                        curve: Curves.linear,
                        left: _isRacing ? trackWidth - 70 : 10,
                        top: 10,
                        child: Icon(racer.icon, color: racer.color, size: 40),
                        onEnd: () => _onFinish(racer.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isRacing ? null : _startRace,
              child: const Text("START RUN"),
            ),
          ),
        ],
      ),
    );
  }
}
