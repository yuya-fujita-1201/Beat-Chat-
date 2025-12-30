import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import 'game_screen.dart';

class DifficultySelectScreen extends ConsumerWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    final selectedCharacter = ref.watch(selectedCharacterProvider);
    final gameDataAsync = ref.watch(gameDataProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '難易度選択',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Selected character preview
              if (selectedCharacter != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getCharacterEmoji(selectedCharacter.id),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedCharacter.name}とトーク！',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              // Difficulty options
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.easy,
                      title: 'Easy',
                      subtitle: '2択でゆったり',
                      description: '初めての方におすすめ！\n選択肢が少なくて迷わない',
                      emoji: '🌸',
                      color: AppColors.mint,
                      choiceCount: 2,
                      isSelected: selectedDifficulty == Difficulty.easy,
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.normal,
                      title: 'Normal',
                      subtitle: '3択でバランス',
                      description: '程よい難しさ！\n会話の幅が広がる',
                      emoji: '⭐',
                      color: AppColors.secondary,
                      choiceCount: 3,
                      isSelected: selectedDifficulty == Difficulty.normal,
                    ),
                    const SizedBox(height: 16),
                    _buildDifficultyCard(
                      context: context,
                      ref: ref,
                      difficulty: Difficulty.hard,
                      title: 'Hard',
                      subtitle: '4択で本気モード',
                      description: '地雷選択肢あり！\n見極め力が試される',
                      emoji: '🔥',
                      color: AppColors.tertiary,
                      choiceCount: 4,
                      isSelected: selectedDifficulty == Difficulty.hard,
                    ),
                  ],
                ),
              ),
              // Start button
              Padding(
                padding: const EdgeInsets.all(24),
                child: gameDataAsync.when(
                  data: (gameData) => GestureDetector(
                    onTap: () {
                      // Set first BGM as default
                      ref.read(selectedBGMProvider.notifier).state =
                          gameData.bgmList.first;
                      // Reset game state
                      ref.read(gameStateProvider.notifier).reset();
                      
                      Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const GameScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
                          Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ゲームスタート！',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, s) => Text('Error: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required BuildContext context,
    required WidgetRef ref,
    required Difficulty difficulty,
    required String title,
    required String subtitle,
    required String description,
    required String emoji,
    required Color color,
    required int choiceCount,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedDifficultyProvider.notifier).state = difficulty;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji and difficulty indicator
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLight,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Choice count indicator
                  Row(
                    children: List.generate(
                      choiceCount,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCharacterEmoji(String id) {
    return switch (id) {
      'dj_gal' => '😎',
      'idol' => '🥰',
      'denpa' => '🌀',
      _ => '😊',
    };
  }
}
