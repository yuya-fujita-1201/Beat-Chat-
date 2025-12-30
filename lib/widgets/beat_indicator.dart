import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/game_models.dart';

class BeatIndicator extends StatelessWidget {
  final double progress;
  final bool isCountIn;
  final int countInBeat;
  final TimingResult? lastResult;

  const BeatIndicator({
    super.key,
    required this.progress,
    this.isCountIn = false,
    this.countInBeat = 0,
    this.lastResult,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring (shrinking)
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 50),
            tween: Tween(begin: progress, end: progress),
            builder: (context, value, child) {
              final scale = 1.5 - (value * 0.5);
              return Container(
                width: 70 * scale,
                height: 70 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getRingColor(),
                    width: 4,
                  ),
                ),
              );
            },
          ),
          // Center dot
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _getCenterColor(),
                  _getCenterColor().withValues(alpha: 0.7),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getCenterColor().withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isCountIn
                ? Center(
                    child: Text(
                      '${8 + countInBeat}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                : null,
          ),
          // Result flash
          if (lastResult != null)
            _buildResultFlash(),
        ],
      ),
    );
  }

  Color _getRingColor() {
    if (isCountIn) return AppColors.secondary;
    if (lastResult == TimingResult.perfect) return AppColors.perfect;
    if (lastResult == TimingResult.good) return AppColors.good;
    if (lastResult == TimingResult.miss) return AppColors.miss;
    return AppColors.primary;
  }

  Color _getCenterColor() {
    if (lastResult == TimingResult.perfect) return AppColors.perfect;
    if (lastResult == TimingResult.good) return AppColors.good;
    if (lastResult == TimingResult.miss) return AppColors.miss;
    return AppColors.accent;
  }

  Widget _buildResultFlash() {
    final color = lastResult == TimingResult.perfect
        ? AppColors.perfect
        : lastResult == TimingResult.good
            ? AppColors.good
            : AppColors.miss;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Container(
          width: 80 * (1 + value * 0.5),
          height: 80 * (1 + value * 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: value),
              width: 3,
            ),
          ),
        );
      },
    );
  }
}

class TimingResultDisplay extends StatelessWidget {
  final TimingResult? result;

  const TimingResultDisplay({super.key, this.result});

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox(height: 30);

    final text = switch (result!) {
      TimingResult.perfect => 'PERFECT!',
      TimingResult.good => 'GOOD!',
      TimingResult.miss => 'MISS...',
    };

    final color = switch (result!) {
      TimingResult.perfect => AppColors.perfect,
      TimingResult.good => AppColors.good,
      TimingResult.miss => AppColors.miss,
    };

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
                shadows: [
                  Shadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
