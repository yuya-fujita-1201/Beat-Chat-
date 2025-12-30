import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class PromptCard extends StatelessWidget {
  final Prompt prompt;
  final bool isLarge;
  final int beatInPhrase;

  const PromptCard({
    super.key,
    required this.prompt,
    this.isLarge = true,
    this.beatInPhrase = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.all(isLarge ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
        border: Border.all(
          color: _getTagColor().withValues(alpha: 0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getTagColor().withValues(alpha: 0.3),
            blurRadius: isLarge ? 20 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tag indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTagColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTagEmoji(),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getTagText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isLarge ? 16 : 8),
          // Prompt text
          Text(
            prompt.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLarge ? 20 : 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          // Beat progress indicator
          if (!isLarge) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isActive = index <= beatInPhrase;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? _getTagColor() : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTagColor() {
    return switch (prompt.tag) {
      'sad' => const Color(0xFF6C9BCF),
      'happy' => const Color(0xFFFFD93D),
      'consult' => const Color(0xFF6BCB77),
      'vent' => const Color(0xFFFF6B6B),
      _ => AppColors.primary,
    };
  }

  String _getTagEmoji() {
    return switch (prompt.tag) {
      'sad' => '😢',
      'happy' => '😄',
      'consult' => '🤔',
      'vent' => '😤',
      _ => '💬',
    };
  }

  String _getTagText() {
    return switch (prompt.tag) {
      'sad' => '落ち込み',
      'happy' => 'うれしい',
      'consult' => '相談',
      'vent' => '愚痴',
      _ => 'トーク',
    };
  }
}

class NewPromptAnimation extends StatefulWidget {
  final Prompt prompt;
  final VoidCallback onComplete;

  const NewPromptAnimation({
    super.key,
    required this.prompt,
    required this.onComplete,
  });

  @override
  State<NewPromptAnimation> createState() => _NewPromptAnimationState();
}

class _NewPromptAnimationState extends State<NewPromptAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward().then((_) {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: PromptCard(prompt: widget.prompt, isLarge: true),
          ),
        );
      },
    );
  }
}
