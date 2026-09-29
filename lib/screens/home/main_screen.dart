import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../betting/betting_screen.dart';
import '../instruction/how_to_play_screen.dart';

class MainScreen extends StatelessWidget {
  final String username;
  final int balance;

  const MainScreen({super.key, required this.username, required this.balance});

  static const _green = Color(0xFF176B3A);
  static const _darkGreen = Color(0xFF0B4226);
  static const _gold = Color(0xFFF2B84B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB9E8F5), Color(0xFFF8E7A7), Color(0xFFFFF7DC)],
          ),
        ),
        child: Stack(
          children: [
            const _BackgroundDecoration(),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth < 360
                      ? 20.0
                      : 28.0;
                  final heroHeight = (constraints.maxHeight * 0.24)
                      .clamp(145.0, 205.0)
                      .toDouble();

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 18,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _BalanceBadge(balance: balance),
                          const _GameTitle(),
                          _RaceHero(height: heroHeight),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _HomeActionButton(
                                  label: 'Start',
                                  icon: Icons.play_arrow_rounded,
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BettingScreen(
                                          username: username,
                                          balance: balance,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                _HomeActionButton(
                                  label: 'How to Play',
                                  icon: Icons.menu_book_rounded,
                                  backgroundColor: const Color(0xFFFFFBEA),
                                  foregroundColor: _darkGreen,
                                  borderColor: const Color(0xFFC89932),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const HowToPlayScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                _HomeActionButton(
                                  label: 'Logout',
                                  icon: Icons.logout_rounded,
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.68,
                                  ),
                                  foregroundColor: const Color(0xFF8B3D2B),
                                  borderColor: const Color(0xFFC9876D),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Pick a racer. Trust your luck. Win the race.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF356444),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -110,
            right: -85,
            child: _softCircle(
              size: 250,
              color: Colors.white.withValues(alpha: 0.33),
            ),
          ),
          Positioned(
            top: 170,
            left: -90,
            child: _softCircle(
              size: 175,
              color: const Color(0xFF65B9A7).withValues(alpha: 0.16),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -55,
            child: _softCircle(
              size: 235,
              color: const Color(0xFFFFD76D).withValues(alpha: 0.24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  final int balance;

  const _BalanceBadge({required this.balance});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0xFFD6A43B), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F5B441B),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.monetization_on_rounded,
              color: Color(0xFFD49A22),
              size: 21,
            ),
            const SizedBox(width: 7),
            Text(
              '$balance Coin',
              style: const TextStyle(
                color: Color(0xFF31542E),
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'HORSE BET',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF0B4226),
            fontSize: 31,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            shadows: [
              Shadow(
                color: Colors.white.withValues(alpha: 0.85),
                offset: const Offset(0, 2),
              ),
              const Shadow(
                color: Color(0x336D4916),
                offset: Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'RACING',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF23844B),
            fontSize: 38,
            height: 0.95,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.8,
          ),
        ),
      ],
    );
  }
}

class _RaceHero extends StatelessWidget {
  final double height;

  const _RaceHero({required this.height});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/image/login_uma1.jpg', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x1155C2D4), Color(0x520B4226)],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 13,
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: MainScreen._gold,
                      size: 22,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'THE TRACK IS READY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.96),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.9,
                        fontSize: 12,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback onPressed;

  const _HomeActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 23),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 5,
          shadowColor: const Color(0x4D28502D),
          side: BorderSide(color: borderColor ?? backgroundColor, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
