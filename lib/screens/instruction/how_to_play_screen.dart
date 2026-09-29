import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hướng Dẫn Chơi'), centerTitle: true),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InstructionSection(
                title: 'Mục tiêu',
                icon: Icons.emoji_events_outlined,
                children: [
                  Text(
                    'Chọn tay đua mà bạn tin sẽ về đích đầu tiên, '
                    'đặt cược hợp lý và cố gắng tăng số coin của mình.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _InstructionSection(
                title: 'Các bước chơi',
                icon: Icons.format_list_numbered,
                children: [
                  _InstructionStepTile(
                    step: 1,
                    title: 'Kiểm tra số dư',
                    description: 'Bạn bắt đầu trò chơi với 100 coin.',
                  ),
                  _InstructionStepTile(
                    step: 2,
                    title: 'Chọn tay đua',
                    description:
                        'Cuộc đua gồm 3 tay đua. Hãy chọn tay đua '
                        'mà bạn nghĩ sẽ chiến thắng.',
                  ),
                  _InstructionStepTile(
                    step: 3,
                    title: 'Nhập tiền cược',
                    description:
                        'Nhập số coin muốn cược. Tổng tiền cược '
                        'không được vượt quá số dư hiện có.',
                  ),
                  _InstructionStepTile(
                    step: 4,
                    title: 'Bắt đầu cuộc đua',
                    description:
                        'Nhấn nút Bắt đầu cuộc đua sau khi đã đặt cược.',
                  ),
                  _InstructionStepTile(
                    step: 5,
                    title: 'Theo dõi cuộc đua',
                    description:
                        'Ba tay đua chạy đồng thời với tốc độ ngẫu nhiên. '
                        'Tay đua về đích đầu tiên là người chiến thắng.',
                  ),
                  _InstructionStepTile(
                    step: 6,
                    title: 'Xem kết quả',
                    description:
                        'Màn hình kết quả hiển thị người chiến thắng, '
                        'tổng tiền cược, tiền nhận được và số dư mới.',
                  ),
                ],
              ),
              SizedBox(height: 16),
              _InstructionSection(
                title: 'Luật cược',
                icon: Icons.monetization_on_outlined,
                children: [
                  Text(
                    '• Phải đặt ít nhất một cược trước khi bắt đầu.',
                    style: TextStyle(fontSize: 15, height: 1.6),
                  ),
                  Text(
                    '• Tổng tiền cược không được vượt quá số coin hiện có.',
                    style: TextStyle(fontSize: 15, height: 1.6),
                  ),
                  Text(
                    '• Nếu đoán đúng, bạn nhận tổng cộng gấp đôi '
                    'số coin đã cược vào tay đua chiến thắng.',
                    style: TextStyle(fontSize: 15, height: 1.6),
                  ),
                  Text(
                    '• Nếu đoán sai, bạn mất số coin đã cược.',
                    style: TextStyle(fontSize: 15, height: 1.6),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Chúc bạn may mắn!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InstructionSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InstructionStepTile extends StatelessWidget {
  final int step;
  final String title;
  final String description;

  const _InstructionStepTile({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            child: Text(
              '$step',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
