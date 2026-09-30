import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/bet_model.dart';
import '../../models/racer_model.dart';
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
  static const _tick = Duration(milliseconds: 100);

  final _engine = RaceEngineImpl();
  final _random = Random();
  late List<Duration> _durations;
  late List<double> _progress; // 0.0 = xuất phát, 1.0 = đích
  Timer? _timer;
  int? _countdown;
  bool _isRacing = false;
  int? _winnerId;

  bool get _hasStarted => _countdown != null || _isRacing || _winnerId != null;

  @override
  void initState() {
    super.initState();
    _durations = _engine.calculateDurations(
      racerCount: widget.racers.length,
      baseDurationSeconds: widget.baseDurationSeconds,
    );
    _progress = List.filled(widget.racers.length, 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRace() {
    setState(() => _countdown = 3);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown! > 1) {
        setState(() => _countdown = _countdown! - 1);
        return;
      }
      timer.cancel();
      setState(() {
        _countdown = null;
        _isRacing = true;
      });
      _timer = Timer.periodic(_tick, (_) => _step());
    });
  }

  void _step() {
    int? leader;
    setState(() {
      for (var i = 0; i < _progress.length; i++) {
        final avgStep = _tick.inMilliseconds / _durations[i].inMilliseconds;
        _progress[i] += avgStep * (0.5 + _random.nextDouble());
        if (_progress[i] >= 1 &&
            (leader == null || _progress[i] > _progress[leader!])) {
          leader = i;
        }
      }
    });
    if (leader != null) _onFinish(widget.racers[leader!].id);
  }

  void _onFinish(int racerId) {
    if (_winnerId != null) return;
    _timer?.cancel();
    setState(() {
      _winnerId = racerId;
      _isRacing = false;
    });
    final result = _engine.calculateResult(
      bets: widget.bets,
      winnerId: racerId,
      currentBalance: widget.currentBalance,
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
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

  int _betFor(Racer racer) => widget.bets
      .where((bet) => bet.racerId == racer.id)
      .fold(0, (sum, bet) => sum + bet.betAmount);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasStarted,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Dark Slate
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "ĐƯỜNG ĐUA KỊCH TÍNH",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          automaticallyImplyLeading: !_hasStarted,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Bảng Trạng Thái Race Header
              _buildStatusHeader(),

              const SizedBox(height: 12),

              // 2. Danh Sách Làn Đua
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.racers.length,
                  itemBuilder: (context, i) {
                    final racer = widget.racers[i];
                    return _RaceLane(
                      racer: racer,
                      laneIndex: i + 1,
                      progress: min(_progress[i], 1.0),
                      betAmount: _betFor(racer),
                      isWinner: racer.id == _winnerId,
                      stepDuration: _tick,
                    );
                  },
                ),
              ),

              // 3. Nút Điều Khiển Bắt Đầu
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildStartButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    Widget content;

    if (_countdown != null) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B), size: 28),
          const SizedBox(width: 8),
          Text(
            "CHUẨN BỊ: $_countdown",
            style: const TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      );
    } else if (_isRacing) {
      content = const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
          SizedBox(width: 12),
          Text(
            "CUỘC ĐUA ĐANG DIỄN RA!",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      );
    } else if (_winnerId != null) {
      final winner = widget.racers.firstWhere((r) => r.id == _winnerId);
      content = Text(
        "🏆 ${winner.name} về nhất!",
        style: const TextStyle(
          color: Color(0xFFFBBF24),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      content = const Text(
        "Nhấn START để bắt đầu",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: content),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _hasStarted
            ? null
            : const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        color: _hasStarted ? const Color(0xFF334155) : null,
        boxShadow: _hasStarted
            ? []
            : [
          BoxShadow(
            color: Color(0xFFF59E0B).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _hasStarted ? null : _startRace,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: _hasStarted ? Colors.white38 : Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              "START RUN",
              style: TextStyle(
                color: _hasStarted ? Colors.white38 : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thiết kế làn đua dạng thảm cỏ / đường ray sang trọng
class _RaceLane extends StatelessWidget {
  static const _racerSize = 44.0;
  static const _finishWidth = 18.0;

  final Racer racer;
  final int laneIndex;
  final double progress;
  final int betAmount;
  final bool isWinner;
  final Duration stepDuration;

  const _RaceLane({
    required this.racer,
    required this.laneIndex,
    required this.progress,
    required this.betAmount,
    required this.isWinner,
    required this.stepDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWinner ? const Color(0xFFFBBF24) : const Color(0xFF334155),
          width: isWinner ? 2.5 : 1,
        ),
        boxShadow: isWinner
            ? [
          BoxShadow(
            color: Color(0xFFFBBF24).withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thông tin Chiến Mã & Cược
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: racer.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: racer.color, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    "$laneIndex",
                    style: TextStyle(
                      color: racer.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                racer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              if (betAmount > 0)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Color(0xFFFBBF24), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "Cược: $betAmount Coin",
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text(
                  "Không cược",
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Đường đua (Track)
          Container(
            height: 56,
            decoration: BoxDecoration(
              // Nền xanh đường cỏ (Turf)
              color: const Color(0xFF0F2E1B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxLeft =
                    constraints.maxWidth - _racerSize - _finishWidth - 4;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Kẻ vạch giữa làn đua
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ),

                    // Vạch xuất phát
                    Positioned(
                      left: _racerSize,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: Colors.white38,
                      ),
                    ),

                    // Vạch đích kẻ ô đen trắng
                    const Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: _finishWidth,
                      child: _FinishLine(),
                    ),

                    // Con ngựa di chuyển
                    AnimatedPositioned(
                      duration: stepDuration,
                      curve: Curves.linear,
                      left: 2 + progress * maxLeft,
                      top: (56 - _racerSize) / 2,
                      child: Container(
                        width: _racerSize,
                        height: _racerSize,
                        decoration: BoxDecoration(
                          color: racer.color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: racer.color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: racer.color.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          racer.icon,
                          color: racer.color,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Vạch đích ô cờ đen trắng sắc nét
class _FinishLine extends StatelessWidget {
  const _FinishLine();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(9),
        bottomRight: Radius.circular(9),
      ),
      child: Column(
        children: List.generate(
          8,
              (row) => Expanded(
            child: Row(
              children: List.generate(
                2,
                    (col) => Expanded(
                  child: Container(
                    color: (row + col).isEven ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
