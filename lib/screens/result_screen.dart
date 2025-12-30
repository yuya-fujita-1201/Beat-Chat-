import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';
import 'title_screen.dart';
import 'game_screen.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final character = ref.watch(selectedCharacterProvider);
    final score = gameState.score;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Result header
                  const Text(
                    '🎉 RESULT 🎉',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Rank display
                  _buildRankDisplay(score.rank),
                  const SizedBox(height: 24),
                  // Character reaction
                  if (character != null) _buildCharacterReaction(character, score),
                  const SizedBox(height: 24),
                  // Score card
                  _buildScoreCard(score),
                  const SizedBox(height: 16),
                  // Timing breakdown
                  _buildTimingBreakdown(score),
                  const SizedBox(height: 16),
                  // Stats
                  _buildStatsCard(score),
                  const SizedBox(height: 32),
                  // Action buttons
                  _buildActionButtons(context, ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankDisplay(String rank) {
    final color = switch (rank) {
      'S' => AppColors.perfect,
      'A' => AppColors.primary,
      'B' => AppColors.good,
      'C' => AppColors.secondary,
      _ => AppColors.miss,
    };

    final message = switch (rank) {
      'S' => '✨ PERFECT!! ✨',
      'A' => '🌟 すごい！',
      'B' => '⭐ いい感じ！',
      'C' => '💪 まずまず！',
      _ => '😅 ドンマイ！',
    };

    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withValues(alpha: 0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCharacterReaction(character, score) {
    final emoji = score.gauge >= 70
        ? '😆'
        : score.gauge >= 40
            ? '😊'
            : '😅';

    final message = score.gauge >= 70
        ? '最高に楽しかった！また話そう♪'
        : score.gauge >= 40
            ? 'いい感じのトークだったね！'
            : 'ちょっと噛み合わなかったかも？';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getCharacterColor(character.id),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  character.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getCharacterColor(character.id),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCharacterColor(String id) {
    return switch (id) {
      'dj_gal' => AppColors.djGal,
      'idol' => AppColors.idol,
      'denpa' => AppColors.denpa,
      _ => AppColors.primary,
    };
  }

  Widget _buildScoreCard(score) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL SCORE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ).createShader(bounds),
            child: Text(
              '${score.totalScore}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Max combo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.secondaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'MAX COMBO: ${score.maxCombo}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingBreakdown(score) {
    final total = score.perfectCount + score.goodCount + score.missCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'TIMING',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTimingItem(
                'PERFECT',
                score.perfectCount,
                AppColors.perfect,
                '⭐',
              ),
              _buildTimingItem(
                'GOOD',
                score.goodCount,
                AppColors.good,
                '👍',
              ),
              _buildTimingItem(
                'MISS',
                score.missCount,
                AppColors.miss,
                '💨',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Row(
                children: [
                  if (score.perfectCount > 0)
                    Expanded(
                      flex: score.perfectCount,
                      child: Container(
                        height: 12,
                        color: AppColors.perfect,
                      ),
                    ),
                  if (score.goodCount > 0)
                    Expanded(
                      flex: score.goodCount,
                      child: Container(
                        height: 12,
                        color: AppColors.good,
                      ),
                    ),
                  if (score.missCount > 0)
                    Expanded(
                      flex: score.missCount,
                      child: Container(
                        height: 12,
                        color: AppColors.miss,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimingItem(String label, int count, Color color, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'VIBE GAUGE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getVibeEmoji(score.gauge),
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Text(
                '${score.gauge.toInt()}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getVibeColor(score.gauge),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.gauge / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getVibeColor(score.gauge),
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getVibeMessage(score.gauge),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  String _getVibeEmoji(double gauge) {
    if (gauge >= 80) return '🥰';
    if (gauge >= 60) return '😊';
    if (gauge >= 40) return '🙂';
    if (gauge >= 20) return '😐';
    return '😓';
  }

  Color _getVibeColor(double gauge) {
    if (gauge >= 70) return AppColors.good;
    if (gauge >= 30) return AppColors.secondary;
    return AppColors.miss;
  }

  String _getVibeMessage(double gauge) {
    if (gauge >= 80) return '最高のトークだった！';
    if (gauge >= 60) return 'いい雰囲気だったね！';
    if (gauge >= 40) return 'まあまあの会話だった';
    if (gauge >= 20) return 'ちょっと微妙だったかも';
    return '空気が読めてなかった...';
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Retry button
        GestureDetector(
          onTap: () {
            ref.read(gameStateProvider.notifier).reset();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GameScreen()),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.replay_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'もう一回！',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Title button
        GestureDetector(
          onTap: () {
            ref.read(gameStateProvider.notifier).reset();
            ref.read(selectedCharacterProvider.notifier).state = null;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const TitleScreen()),
              (route) => false,
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text(
                  'タイトルへ',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
