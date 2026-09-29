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
        appBar: AppBar(
          title: const Text('Kết Quả Cuộc Đua'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '🏆 Người thắng: ${winner.name}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Table(
                    border: TableBorder.all(color: Colors.grey.shade400),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.5),
                      2: FlexColumnWidth(1.5),
                    },
                    children: [
                      const TableRow(
                        children: [
                          _ResultCell('Đối tượng', bold: true),
                          _ResultCell('Tiền cược', bold: true),
                          _ResultCell('Kết quả', bold: true),
                        ],
                      ),
                      for (final racer in widget.racers) _rowFor(racer),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Tổng cược: ${widget.result.totalBet} Coin'),
                  Text('Nhận về: ${widget.result.totalPayout} Coin'),
                  Text('Lãi/lỗ ván này: ${change >= 0 ? '+' : ''}$change Coin'),
                  Text(
                    'Số dư mới: ${widget.result.newBalance} Coin',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_saving) const Center(child: CircularProgressIndicator()),
                  if (!_saving && !_saved) ...[
                    const Text('Không thể lưu số dư. Vui lòng thử lại.'),
                    OutlinedButton(
                      onPressed: _saveBalance,
                      child: const Text('Thử lưu lại'),
                    ),
                  ],
                  ElevatedButton(
                    onPressed: _saved
                        ? () => _goTo(
                            BettingScreen(
                              username: widget.username,
                              balance: widget.result.newBalance,
                            ),
                          )
                        : null,
                    child: const Text('Play Again'),
                  ),
                  OutlinedButton(
                    onPressed: _saved
                        ? () => _goTo(
                            MainScreen(
                              username: widget.username,
                              balance: widget.result.newBalance,
                            ),
                          )
                        : null,
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _rowFor(Racer racer) {
    final amount = widget.result.bets
        .where((bet) => bet.racerId == racer.id)
        .fold<int>(0, (sum, bet) => sum + bet.betAmount);
    final status = amount == 0
        ? 'Không cược'
        : racer.id == widget.result.winnerRacerId
        ? 'Win'
        : 'Lose';
    return TableRow(
      children: [
        _ResultCell(racer.name),
        _ResultCell('$amount Coin'),
        _ResultCell(status),
      ],
    );
  }
}

class _ResultCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _ResultCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
