import 'package:flutter/material.dart';
import '../models/game_models.dart';
import '../utils/app_theme.dart';

class CharacterDisplay extends StatelessWidget {
  final GameCharacter character;
  final Expression expression;
  final double size;

  const CharacterDisplay({
    super.key,
    required this.character,
    this.expression = Expression.normal,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Character avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getCharacterColor(),
                _getCharacterColor().withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _getCharacterColor().withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          child: Center(
            child: Text(
              _getExpressionEmoji(),
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Character name
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
              ),
            ],
          ),
          child: Text(
            character.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getCharacterColor(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCharacterColor() {
    return switch (character.id) {
      'dj_gal' => AppColors.djGal,
      'idol' => AppColors.idol,
      'denpa' => AppColors.denpa,
      _ => AppColors.primary,
    };
  }

  String _getExpressionEmoji() {
    return switch (expression) {
      Expression.normal => _getNormalEmoji(),
      Expression.happy => '😆',
      Expression.shy => '😊',
      Expression.angry => '😤',
      Expression.confused => '😵',
    };
  }

  String _getNormalEmoji() {
    return switch (character.id) {
      'dj_gal' => '😎',
      'idol' => '🥰',
      'denpa' => '🌀',
      _ => '😊',
    };
  }
}

class CharacterSelectCard extends StatelessWidget {
  final GameCharacter character;
  final bool isSelected;
  final VoidCallback onTap;

  const CharacterSelectCard({
    super.key,
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _getCharacterColor() : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _getCharacterColor().withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    _getCharacterColor(),
                    _getCharacterColor().withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  _getCharacterEmoji(),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              character.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getCharacterColor(),
              ),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              character.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
            // Selection indicator
            if (isSelected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCharacterColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '✓ 選択中',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCharacterColor() {
    return switch (character.id) {
      'dj_gal' => AppColors.djGal,
      'idol' => AppColors.idol,
      'denpa' => AppColors.denpa,
      _ => AppColors.primary,
    };
  }

  String _getCharacterEmoji() {
    return switch (character.id) {
      'dj_gal' => '😎',
      'idol' => '🥰',
      'denpa' => '🌀',
      _ => '😊',
    };
  }
}
