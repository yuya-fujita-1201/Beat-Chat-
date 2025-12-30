import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class ChoiceButtons extends StatelessWidget {
  final List<Choice> choices;
  final bool enabled;
  final int? selectedIndex;
  final Function(int index, Choice choice) onChoiceSelected;

  const ChoiceButtons({
    super.key,
    required this.choices,
    required this.enabled,
    this.selectedIndex,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // First row
        Row(
          children: [
            if (choices.isNotEmpty)
              Expanded(
                child: _buildChoiceButton(0, choices[0]),
              ),
            if (choices.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceButton(1, choices[1]),
              ),
            ],
          ],
        ),
        // Second row (for 3 or 4 choices)
        if (choices.length > 2) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(2, choices[2]),
              ),
              if (choices.length > 3) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildChoiceButton(3, choices[3]),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildChoiceButton(int index, Choice choice) {
    final isSelected = selectedIndex == index;
    final buttonColor = _getButtonColor(choice, isSelected);

    return GestureDetector(
      onTap: enabled ? () => onChoiceSelected(index, choice) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [buttonColor, buttonColor.withValues(alpha: 0.8)],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: buttonColor,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? buttonColor : Colors.black).withValues(alpha: isSelected ? 0.3 : 0.1),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Index circle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : buttonColor,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isSelected ? buttonColor : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Response text
            Expanded(
              child: Text(
                choice.response.text,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Type indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isSelected ? Colors.white : buttonColor).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getTypeEmoji(choice.response.type),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(Choice choice, bool isSelected) {
    if (choice.isMine) return AppColors.miss;
    
    return switch (choice.response.type) {
      'empathy' => const Color(0xFF6C9BCF),
      'acceptance' => const Color(0xFF95D5B2),
      'question' => const Color(0xFFFFB347),
      'encourage' => const Color(0xFFFF6B6B),
      'celebrate' => const Color(0xFFFFD93D),
      'suggest' => const Color(0xFF6BCB77),
      'tsukkomi' => const Color(0xFFBA68C8),
      'meme' => const Color(0xFF9370DB),
      'logic' => const Color(0xFF78909C),
      'close' => const Color(0xFFFF69B4),
      _ => AppColors.primary,
    };
  }

  String _getTypeEmoji(String type) {
    return switch (type) {
      'empathy' => '💙',
      'acceptance' => '👍',
      'question' => '❓',
      'encourage' => '💪',
      'celebrate' => '🎉',
      'suggest' => '💡',
      'tsukkomi' => '😂',
      'meme' => '✨',
      'logic' => '🧠',
      'close' => '💕',
      _ => '💬',
    };
  }
}

class ChoiceButtonsShimmer extends StatelessWidget {
  final int count;

  const ChoiceButtonsShimmer({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerButton()),
            if (count > 1) ...[
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerButton()),
            ],
          ],
        ),
        if (count > 2) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerButton()),
              if (count > 3) ...[
                const SizedBox(width: 12),
                Expanded(child: _buildShimmerButton()),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildShimmerButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
