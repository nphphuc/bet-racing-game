import 'package:flutter/material.dart';

import '../../models/bet_model.dart';
import '../../models/racer_model.dart';
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
  int _baseDurationSeconds = 5;
  int _totalBet = 0;

  @override
  void initState() {
    super.initState();
    _racers = _racerRepo.getRacers();

    // Lắng nghe thay đổi tiền cược để tính tổng real-time
    for (final controller in _betControllers) {
      controller.addListener(_calculateTotalBet);
    }
  }

  @override
  void dispose() {
    for (final controller in _betControllers) {
      controller.removeListener(_calculateTotalBet);
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateTotalBet() {
    int sum = 0;
    for (final controller in _betControllers) {
      final val = int.tryParse(controller.text.trim()) ?? 0;
      if (val > 0) sum += val;
    }
    setState(() {
      _totalBet = sum;
    });
  }

  void _addBet(int index, int amount) {
    final current = int.tryParse(_betControllers[index].text.trim()) ?? 0;
    final newValue = current + amount;
    _betControllers[index].text = newValue.toString();
  }

  void _clearBet(int index) {
    _betControllers[index].clear();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = widget.balance - _totalBet;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark Slate Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SẢNH ĐẶT CƯỢC",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Khung hiển thị Số dư & Tổng cược
                    _buildBalanceCard(remainingBalance),

                    const SizedBox(height: 16),

                    // 2. Tùy chỉnh thời gian đường đua
                    _buildDurationSliderCard(),

                    const SizedBox(height: 20),

                    // 3. Tiêu đề danh sách chiến mã
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        "CHỌN CHIẾN MÃ & MỨC CƯỢC",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),

                    // 4. Danh sách 3 chiến mã đặt cược
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _racers.length,
                      itemBuilder: (context, i) {
                        return _buildRacerBetCard(i);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 5. Nút Bắt đầu cuộc đua cố định bên dưới
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSubmitButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(int remainingBalance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Số dư ban đầu
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SỐ DƯ HIỆN CÓ",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFBBF24), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "${widget.balance}",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),

          Container(width: 1, height: 36, color: const Color(0xFF334155)),

          // Tổng cược hiện tại
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "TỔNG ĐẶT CƯỢC",
                style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "$_totalBet Coin",
                style: TextStyle(
                  color: _totalBet > widget.balance ? Colors.redAccent : const Color(0xFFF59E0B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSliderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer_rounded, color: Color(0xFFF59E0B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Thời Gian Đua Trung Bình",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                ),
                child: Text(
                  "$_baseDurationSeconds GIÂY",
                  style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF59E0B),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: const Color(0xFFFBBF24),
              overlayColor: Color(0xFFF59E0B).withValues(alpha: 0.2),
              valueIndicatorTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _baseDurationSeconds.toDouble(),
              min: 3,
              max: 15,
              divisions: 12,
              onChanged: (val) => setState(() => _baseDurationSeconds = val.toInt()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRacerBetCard(int index) {
    final racer = _racers[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar Ngựa
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: racer.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: racer.color, width: 1.5),
                ),
                child: Icon(racer.icon, color: racer.color, size: 26),
              ),
              const SizedBox(width: 12),

              // Tên Chiến Mã
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      racer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Làn số ${index + 1}",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Ô nhập cược
              SizedBox(
                width: 110,
                child: TextField(
                  controller: _betControllers[index],
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.end,
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: const TextStyle(color: Colors.white24),
                    suffixText: "Coin",
                    suffixStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Các phím chọn nhanh mức cược
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildQuickBetChip("+10", () => _addBet(index, 10)),
              const SizedBox(width: 6),
              _buildQuickBetChip("+50", () => _addBet(index, 50)),
              const SizedBox(width: 6),
              _buildQuickBetChip("+100", () => _addBet(index, 100)),
              const SizedBox(width: 6),
              _buildQuickBetChip("Xóa", () => _clearBet(index), isClear: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickBetChip(String label, VoidCallback onTap, {bool isClear = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isClear ? Colors.redAccent.withValues(alpha: 0.15) : const Color(0xFF334155),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isClear ? Colors.redAccent.withValues(alpha: 0.5) : const Color(0xFF475569),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isClear ? Colors.redAccent : Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        ),
        boxShadow: [
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
        onPressed: _startRace,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_score_rounded, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "Bắt đầu cuộc đua",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}