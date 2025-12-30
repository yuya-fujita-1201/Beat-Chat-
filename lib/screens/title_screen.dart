import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';
import 'character_select_screen.dart';

class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameDataAsync = ref.watch(gameDataProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo area
                _buildLogo(),
                const SizedBox(height: 20),
                // Subtitle
                const Text(
                  '〜リズムで繋がるトークゲーム〜',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
                // Start button
                gameDataAsync.when(
                  data: (gameData) => _buildStartButton(context, ref),
                  loading: () => const CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                  error: (error, stack) => Column(
                    children: [
                      const Icon(Icons.error, color: AppColors.miss, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'データ読み込みエラー',
                        style: TextStyle(color: AppColors.miss),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Decorative elements
                _buildDecorations(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Music note decorations
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFloatingNote('♪', AppColors.primary, -10),
            const SizedBox(width: 20),
            _buildFloatingNote('♫', AppColors.secondary, 10),
            const SizedBox(width: 20),
            _buildFloatingNote('♪', AppColors.accent, -5),
          ],
        ),
        const SizedBox(height: 16),
        // Main title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.primary, AppColors.secondary, AppColors.accent],
          ).createShader(bounds),
          child: const Text(
            'Beat Chat',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Chat bubble decoration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('💬', style: TextStyle(fontSize: 24)),
              SizedBox(width: 8),
              Text(
                'タップでトーク！',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(width: 8),
              Text('🎵', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingNote(String note, Color color, double offset) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 2),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offset * (0.5 + 0.5 * (value * 2 * 3.14159).sin())),
          child: Text(
            note,
            style: TextStyle(
              fontSize: 32,
              color: color,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const CharacterSelectScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                SizedBox(width: 8),
                Text(
                  'START',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // How to play hint
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '🎮 拍に合わせてタップ！会話を繋げよう',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorations() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecoItem('⭐', AppColors.secondary),
        const SizedBox(width: 16),
        _buildDecoItem('💖', AppColors.primary),
        const SizedBox(width: 16),
        _buildDecoItem('✨', AppColors.accent),
        const SizedBox(width: 16),
        _buildDecoItem('🌟', AppColors.secondary),
      ],
    );
  }

  Widget _buildDecoItem(String emoji, Color glowColor) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}

// Extension for sin function
extension NumExtension on double {
  double sin() => _sin(this);
}

double _sin(double x) {
  // Simple sin approximation
  x = x % (2 * 3.14159);
  double result = x;
  double term = x;
  for (int i = 1; i < 10; i++) {
    term *= -x * x / ((2 * i) * (2 * i + 1));
    result += term;
  }
  return result;
}
