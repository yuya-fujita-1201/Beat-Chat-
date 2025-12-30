import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_models.dart';
import '../services/choice_generator.dart';

// Game Data Provider
final gameDataProvider = FutureProvider<GameData>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/game_data.json');
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;
  return GameData.fromJson(jsonData);
});

// Selected Character Provider
final selectedCharacterProvider = StateProvider<GameCharacter?>((ref) => null);

// Selected Difficulty Provider
final selectedDifficultyProvider = StateProvider<Difficulty>((ref) => Difficulty.normal);

// Selected BGM Provider
final selectedBGMProvider = StateProvider<BGMInfo?>((ref) => null);

// Choice Generator Provider
final choiceGeneratorProvider = Provider.family<ChoiceGenerator?, GameData>((ref, gameData) {
  return ChoiceGenerator(gameData);
});

// Game State
enum GamePhase { ready, countIn, playing, paused, finished }

class GameState {
  final GamePhase phase;
  final int currentBeat;
  final int beatInPhrase;
  final int phraseNumber;
  final Prompt? currentPrompt;
  final List<Choice> currentChoices;
  final GameScore score;
  final Expression characterExpression;
  final TimingResult? lastTimingResult;
  final bool inputAccepted;

  GameState({
    this.phase = GamePhase.ready,
    this.currentBeat = -8,
    this.beatInPhrase = 0,
    this.phraseNumber = 0,
    this.currentPrompt,
    this.currentChoices = const [],
    GameScore? score,
    this.characterExpression = Expression.normal,
    this.lastTimingResult,
    this.inputAccepted = false,
  }) : score = score ?? GameScore();

  GameState copyWith({
    GamePhase? phase,
    int? currentBeat,
    int? beatInPhrase,
    int? phraseNumber,
    Prompt? currentPrompt,
    List<Choice>? currentChoices,
    GameScore? score,
    Expression? characterExpression,
    TimingResult? lastTimingResult,
    bool? inputAccepted,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      currentBeat: currentBeat ?? this.currentBeat,
      beatInPhrase: beatInPhrase ?? this.beatInPhrase,
      phraseNumber: phraseNumber ?? this.phraseNumber,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      currentChoices: currentChoices ?? this.currentChoices,
      score: score ?? this.score,
      characterExpression: characterExpression ?? this.characterExpression,
      lastTimingResult: lastTimingResult,
      inputAccepted: inputAccepted ?? this.inputAccepted,
    );
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(GameState());

  void reset() {
    state = GameState();
  }

  void setPhase(GamePhase phase) {
    state = state.copyWith(phase: phase);
  }

  void updateBeat(int beat, int beatInPhrase, int phraseNumber) {
    state = state.copyWith(
      currentBeat: beat,
      beatInPhrase: beatInPhrase,
      phraseNumber: phraseNumber,
      inputAccepted: false,
      lastTimingResult: null,
    );
  }

  void setPromptAndChoices(Prompt prompt, List<Choice> choices) {
    state = state.copyWith(
      currentPrompt: prompt,
      currentChoices: choices,
    );
  }

  void updateChoices(List<Choice> choices) {
    state = state.copyWith(currentChoices: choices);
  }

  void recordInput(TimingResult timing, Choice choice) {
    final result = BeatResult(
      beatNumber: state.currentBeat,
      timing: timing,
      selectedChoice: choice,
      timingOffset: 0,
      score: 0,
    );
    
    state.score.addResult(result);

    // Determine expression based on fit
    Expression expression;
    if (choice.isMine || choice.response.fit == 'bad') {
      expression = Expression.confused;
    } else if (timing == TimingResult.perfect && choice.response.fit == 'good') {
      expression = Expression.happy;
    } else if (timing == TimingResult.miss) {
      expression = Expression.angry;
    } else if (choice.response.fit == 'good') {
      expression = Expression.shy;
    } else {
      expression = Expression.normal;
    }

    state = state.copyWith(
      inputAccepted: true,
      lastTimingResult: timing,
      characterExpression: expression,
      score: state.score,
    );
  }

  void recordMiss() {
    final result = BeatResult(
      beatNumber: state.currentBeat,
      timing: TimingResult.miss,
      selectedChoice: null,
      timingOffset: 999,
      score: 0,
    );
    
    state.score.addResult(result);
    
    state = state.copyWith(
      inputAccepted: true,
      lastTimingResult: TimingResult.miss,
      characterExpression: Expression.confused,
      score: state.score,
    );
  }

  void setExpression(Expression expression) {
    state = state.copyWith(characterExpression: expression);
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
