import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../services/beat_engine.dart';
import '../services/choice_generator.dart';
import '../widgets/beat_indicator.dart';
import '../widgets/character_display.dart';
import '../widgets/prompt_card.dart';
import '../widgets/choice_buttons.dart';
import 'result_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  BeatEngine? _beatEngine;
  ChoiceGenerator? _choiceGenerator;
  Timer? _progressTimer;
  double _beatProgress = 0.0;
  bool _isStarted = false;
  int _countInDisplay = 8;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  List<Prompt> _shuffledPrompts = [];
  int _currentPromptIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _beatEngine?.dispose();
    _progressTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeGame(GameData gameData) {
    if (_choiceGenerator != null) return;

    final bgm = ref.read(selectedBGMProvider);
    if (bgm == null) return;

    _choiceGenerator = ChoiceGenerator(gameData);
    _choiceGenerator!.reset();

    // Shuffle prompts
    _shuffledPrompts = List.from(gameData.prompts)..shuffle(Random());

    _beatEngine = BeatEngine(
      bgmInfo: bgm,
      onBeat: _onBeat,
      onGameEnd: _onGameEnd,
    );
  }

  void _startGame() {
    if (_isStarted) return;
    setState(() {
      _isStarted = true;
    });

    ref.read(gameStateProvider.notifier).setPhase(GamePhase.countIn);
    _beatEngine!.start();

    // Start progress timer for smooth animation
    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (_beatEngine != null && _beatEngine!.isRunning) {
        setState(() {
          _beatProgress = _beatEngine!.getBeatProgress();
        });
      }
    });
  }

  void _onBeat(int beatNumber, int beatInPhrase, int phraseNumber) {
    final gameState = ref.read(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);
    final character = ref.read(selectedCharacterProvider);
    final difficulty = ref.read(selectedDifficultyProvider);

    // Pulse animation on beat
    _pulseController.forward().then((_) => _pulseController.reverse());

    if (beatNumber < 0) {
      // Count-in phase
      setState(() {
        _countInDisplay = -beatNumber;
      });
      return;
    }

    // Update to playing phase
    if (gameState.phase == GamePhase.countIn) {
      notifier.setPhase(GamePhase.playing);
    }

    // Check if previous beat had no input (miss)
    if (!gameState.inputAccepted && beatNumber > 0) {
      notifier.recordMiss();
    }

    // Update beat info
    notifier.updateBeat(beatNumber, beatInPhrase, phraseNumber);

    // On phrase start (beat 0 of phrase), show new prompt
    if (beatInPhrase == 0 && character != null) {
      final prompt = _shuffledPrompts[_currentPromptIndex % _shuffledPrompts.length];
      _currentPromptIndex++;

      final choices = _choiceGenerator!.generateChoices(
        character: character,
        prompt: prompt,
        beatInPhrase: beatInPhrase,
        difficulty: difficulty,
      );

      notifier.setPromptAndChoices(prompt, choices);
    } else if (character != null && gameState.currentPrompt != null) {
      // Update choices for each beat within phrase
      final choices = _choiceGenerator!.generateChoices(
        character: character,
        prompt: gameState.currentPrompt!,
        beatInPhrase: beatInPhrase,
        difficulty: difficulty,
      );
      notifier.updateChoices(choices);
    }
  }

  void _onGameEnd() {
    _progressTimer?.cancel();
    ref.read(gameStateProvider.notifier).setPhase(GamePhase.finished);

    // Navigate to result screen
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ResultScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  void _onChoiceSelected(int index, Choice choice) {
    final gameState = ref.read(gameStateProvider);
    if (gameState.inputAccepted || gameState.phase != GamePhase.playing) return;

    final inputTime = _beatEngine!.getElapsedTime();
    final timing = _beatEngine!.judgeTiming(inputTime);

    ref.read(gameStateProvider.notifier).recordInput(timing, choice);
    _choiceGenerator!.recordSelection(choice.response.id);
  }

  @override
  Widget build(BuildContext context) {
    final gameDataAsync = ref.watch(gameDataProvider);
    final gameState = ref.watch(gameStateProvider);
    final selectedCharacter = ref.watch(selectedCharacterProvider);
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    final bgm = ref.watch(selectedBGMProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: gameDataAsync.when(
            data: (gameData) {
              _initializeGame(gameData);

              if (!_isStarted) {
                return _buildReadyScreen(bgm);
              }

              return _buildGameScreen(
                gameState: gameState,
                character: selectedCharacter!,
                difficulty: selectedDifficulty,
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadyScreen(BGMInfo? bgm) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🎵 準備OK？',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          if (bgm != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '♪ ${bgm.name}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BPM: ${bgm.bpm} | ${bgm.duration}秒',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startGame,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '8拍のカウント後にスタート！',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen({
    required GameState gameState,
    required GameCharacter character,
    required Difficulty difficulty,
  }) {
    return Column(
      children: [
        // Top bar (score, combo, gauge)
        _buildTopBar(gameState),
        const SizedBox(height: 8),
        // Character display
        ScaleTransition(
          scale: _pulseAnimation,
          child: CharacterDisplay(
            character: character,
            expression: gameState.characterExpression,
            size: 100,
          ),
        ),
        const SizedBox(height: 12),
        // Timing result display
        TimingResultDisplay(result: gameState.lastTimingResult),
        const SizedBox(height: 8),
        // Beat indicator
        BeatIndicator(
          progress: _beatProgress,
          isCountIn: gameState.phase == GamePhase.countIn,
          countInBeat: _countInDisplay,
          lastResult: gameState.lastTimingResult,
        ),
        const SizedBox(height: 16),
        // Prompt card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: gameState.currentPrompt != null
              ? PromptCard(
                  prompt: gameState.currentPrompt!,
                  isLarge: gameState.beatInPhrase == 0,
                  beatInPhrase: gameState.beatInPhrase,
                )
              : _buildCountInDisplay(),
        ),
        const Spacer(),
        // Choice buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: gameState.currentChoices.isNotEmpty
              ? ChoiceButtons(
                  choices: gameState.currentChoices,
                  enabled: !gameState.inputAccepted &&
                      gameState.phase == GamePhase.playing,
                  selectedIndex: null,
                  onChoiceSelected: _onChoiceSelected,
                )
              : ChoiceButtonsShimmer(
                  count: switch (difficulty) {
                    Difficulty.easy => 2,
                    Difficulty.normal => 3,
                    Difficulty.hard => 4,
                  },
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTopBar(GameState gameState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              Text(
                '${gameState.score.totalScore}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          // Combo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              gradient: gameState.score.combo > 0
                  ? AppColors.secondaryGradient
                  : null,
              color: gameState.score.combo > 0 ? null : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                if (gameState.score.combo > 0)
                  const Text('🔥 ', style: TextStyle(fontSize: 16)),
                Text(
                  '${gameState.score.combo} COMBO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: gameState.score.combo > 0
                        ? Colors.white
                        : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          // Gauge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'VIBE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: gameState.score.gauge / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gameState.score.gauge >= 70
                          ? AppColors.good
                          : gameState.score.gauge >= 30
                              ? AppColors.secondary
                              : AppColors.miss,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountInDisplay() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$_countInDisplay',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const Text(
            'カウントイン...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
