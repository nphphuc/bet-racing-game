import 'package:flutter/material.dart';

import '../../models/race_result_model.dart';
import '../../models/racer_model.dart';
import '../../services/balance_repository.dart';
import '../betting/betting_screen.dart';
import '../home/main_screen.dart';

class ResultScreen extends StatefulWidget {
  final RaceResult result;
  final List<Racer> racers;
  final String username;
  final BalanceRepository? balanceRepository;

  const ResultScreen({
    super.key,
    required this.result,
    required this.racers,
    required this.username,
    this.balanceRepository,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _saving = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveBalance();
  }

  Future<void> _saveBalance() async {
    setState(() => _saving = true);
    try {
      await (widget.balanceRepository ?? BalanceRepository()).save(
        widget.username,
        widget.result.newBalance,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _saved = false;
      });
    }
  }

  void _goTo(Widget screen) {
    if (!_saved) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.racers.firstWhere(
          (racer) => racer.id == widget.result.winnerRacerId,
    );
    final change = widget.result.totalPayout - widget.result.totalBet;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'KẾT QUẢ CUỘC ĐUA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Khung Vinh Danh Người Thắng
                  _buildWinnerBanner(winner),

                  const SizedBox(height: 10),

                  // 2. Thống Kê Tài Chính
                  _buildFinancialSummaryCard(change),

                  const SizedBox(height: 10),

                  // 3. Bảng Chi Tiết Kết Quả Đặt Cược
                  _buildBetsTable(),

                  const SizedBox(height: 12),

                  // 4. Trạng Thái Lưu & Nút Thao Tác
                  if (_saving)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: Color(0xFFF59E0B)),
                          SizedBox(height: 4),
                          Text(
                            "Đang đồng bộ số dư...",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                  if (!_saving && !_saved) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Không thể lưu số dư. Vui lòng thử lại.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                          TextButton(
                            onPressed: _saveBalance,
                            child: const Text('Thử lưu lại', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Nút Chơi Tiếp
                  _buildPrimaryActionButton(
                    title: "Play Again",
                    icon: Icons.replay_rounded,
                    onTap: _saved
                        ? () => _goTo(
                      BettingScreen(
                        username: widget.username,
                        balance: widget.result.newBalance,
                      ),
                    )
                        : null,
                  ),

                  const SizedBox(height: 8),

                  // Nút Trở Về Sảnh
                  _buildSecondaryActionButton(
                    title: "Back to Home",
                    icon: Icons.home_rounded,
                    onTap: _saved
                        ? () => _goTo(
                      MainScreen(
                        username: widget.username,
                        balance: widget.result.newBalance,
                      ),
                    )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerBanner(Racer winner) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFBBF24), size: 24),
              const SizedBox(width: 6),
              Text(
                "🏆 Người thắng: ${winner.name}",
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: winner.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: winner.color, width: 2),
                ),
                child: Icon(winner.icon, color: winner.color, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                winner.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(int change) {
    final isProfit = change >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Tổng cược", "${widget.result.totalBet} Coin", Colors.white70),
              _buildStatItem("Nhận về", "${widget.result.totalPayout} Coin", const Color(0xFFFBBF24)),
              _buildStatItem(
                "Lãi / Lỗ",
                "${isProfit ? '+' : ''}$change Coin",
                isProfit ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF334155), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SỐ DƯ MỚI",
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
              Row(
                children: [
                  Text(
                    "Số dư mới: ${widget.result.newBalance} Coin",
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBetsTable() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              "CHI TIẾT ĐẶT CƯỢC",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Divider(color: Color(0xFF334155), height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.racers.length,
            separatorBuilder: (context, index) => const Divider(color: Color(0xFF334155), height: 1),
            itemBuilder: (context, index) {
              final racer = widget.racers[index];
              final amount = widget.result.bets
                  .where((bet) => bet.racerId == racer.id)
                  .fold<int>(0, (sum, bet) => sum + bet.betAmount);
              final isWinner = racer.id == widget.result.winnerRacerId;

              String statusText;
              Color statusColor;
              Color statusBg;

              if (amount == 0) {
                statusText = 'Không cược';
                statusColor = Colors.white38;
                statusBg = Colors.white.withValues(alpha: 0.05);
              } else if (isWinner) {
                statusText = 'Win';
                statusColor = Colors.greenAccent;
                statusBg = Colors.greenAccent.withValues(alpha: 0.15);
              } else {
                statusText = 'Lose';
                statusColor = Colors.redAccent;
                statusBg = Colors.redAccent.withValues(alpha: 0.15);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(racer.icon, color: racer.color, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        racer.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Text(
                      amount > 0 ? '$amount Coin' : '-',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF59E0B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF334155),
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: onTap == null ? 0 : 4,
          shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.3),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required String title,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white70,
          disabledBackgroundColor: const Color(0xFF334155),
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: onTap == null ? const Color(0xFF334155) : const Color(0xFF475569),
            ),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
