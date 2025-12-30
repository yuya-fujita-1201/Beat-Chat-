import 'dart:math';
import '../models/game_models.dart';

class ChoiceGenerator {
  final GameData gameData;
  final Random _random = Random();
  final List<String> _recentResponseIds = [];
  static const int _historyLimit = 8;

  ChoiceGenerator(this.gameData);

  List<Choice> generateChoices({
    required GameCharacter character,
    required Prompt prompt,
    required int beatInPhrase,
    required Difficulty difficulty,
  }) {
    final int choiceCount = switch (difficulty) {
      Difficulty.easy => 2,
      Difficulty.normal => 3,
      Difficulty.hard => 4,
    };

    final List<Choice> choices = [];
    final String recommendedType = prompt.recommend[beatInPhrase.clamp(0, 3)];
    
    // 1. Get good response based on recommended type
    final goodResponse = _selectResponseByType(
      character: character,
      promptTag: prompt.tag,
      preferredType: recommendedType,
      excludeIds: _recentResponseIds,
    );
    if (goodResponse != null) {
      choices.add(Choice(
        response: goodResponse,
        weight: character.getWeight(prompt.tag, goodResponse.type),
      ));
    }

    // 2. Add neutral response (acceptance/empathy with low weight)
    final neutralResponse = _selectNeutralResponse(
      excludeIds: [..._recentResponseIds, ...choices.map((c) => c.response.id)],
    );
    if (neutralResponse != null) {
      choices.add(Choice(
        response: neutralResponse,
        weight: character.getWeight(prompt.tag, neutralResponse.type),
      ));
    }

    // 3. For Normal/Hard: Add runner-up response
    if (difficulty != Difficulty.easy && choices.length < choiceCount) {
      final runnerUpTypes = prompt.recommend
          .where((t) => t != recommendedType)
          .toList();
      
      if (runnerUpTypes.isNotEmpty) {
        final runnerUpResponse = _selectResponseByType(
          character: character,
          promptTag: prompt.tag,
          preferredType: runnerUpTypes[_random.nextInt(runnerUpTypes.length)],
          excludeIds: [..._recentResponseIds, ...choices.map((c) => c.response.id)],
        );
        if (runnerUpResponse != null) {
          choices.add(Choice(
            response: runnerUpResponse,
            weight: character.getWeight(prompt.tag, runnerUpResponse.type),
          ));
        }
      }
    }

    // 4. For Hard: Add mine (bad) response
    if (difficulty == Difficulty.hard && choices.length < choiceCount) {
      final mineResponse = _selectMineResponse(
        promptTag: prompt.tag,
        excludeIds: choices.map((c) => c.response.id).toList(),
      );
      if (mineResponse != null) {
        choices.add(Choice(
          response: mineResponse,
          weight: 0.1,
          isMine: true,
        ));
      }
    }

    // Fill remaining slots with random responses
    while (choices.length < choiceCount) {
      final randomResponse = _selectRandomResponse(
        excludeIds: [..._recentResponseIds, ...choices.map((c) => c.response.id)],
      );
      if (randomResponse != null) {
        choices.add(Choice(
          response: randomResponse,
          weight: character.getWeight(prompt.tag, randomResponse.type),
        ));
      } else {
        break;
      }
    }

    // Shuffle choices
    choices.shuffle(_random);

    return choices;
  }

  Response? _selectResponseByType({
    required GameCharacter character,
    required String promptTag,
    required String preferredType,
    required List<String> excludeIds,
  }) {
    final candidates = gameData.responseBank
        .where((r) => r.type == preferredType && !excludeIds.contains(r.id))
        .toList();

    if (candidates.isEmpty) return null;

    // Weight-based selection
    final weights = candidates.map((r) {
      return character.getWeight(promptTag, r.type);
    }).toList();

    final totalWeight = weights.fold(0.0, (sum, w) => sum + w);
    if (totalWeight <= 0) return candidates[_random.nextInt(candidates.length)];

    double roll = _random.nextDouble() * totalWeight;
    for (int i = 0; i < candidates.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return candidates[i];
    }

    return candidates.last;
  }

  Response? _selectNeutralResponse({required List<String> excludeIds}) {
    final neutralTypes = ['acceptance', 'empathy'];
    final candidates = gameData.responseBank
        .where((r) => neutralTypes.contains(r.type) && 
                      r.fit == 'neutral' && 
                      !excludeIds.contains(r.id))
        .toList();

    if (candidates.isEmpty) {
      // Fallback to any neutral response
      final fallback = gameData.responseBank
          .where((r) => r.fit == 'neutral' && !excludeIds.contains(r.id))
          .toList();
      if (fallback.isEmpty) return null;
      return fallback[_random.nextInt(fallback.length)];
    }

    return candidates[_random.nextInt(candidates.length)];
  }

  Response? _selectMineResponse({
    required String promptTag,
    required List<String> excludeIds,
  }) {
    // First try tag-specific mines
    final tagMines = gameData.mineResponses
        .where((r) => r.forTag == promptTag && !excludeIds.contains(r.id))
        .toList();

    if (tagMines.isNotEmpty) {
      return tagMines[_random.nextInt(tagMines.length)];
    }

    // Fallback to any mine
    final anyMines = gameData.mineResponses
        .where((r) => !excludeIds.contains(r.id))
        .toList();

    if (anyMines.isEmpty) return null;
    return anyMines[_random.nextInt(anyMines.length)];
  }

  Response? _selectRandomResponse({required List<String> excludeIds}) {
    final candidates = gameData.responseBank
        .where((r) => !excludeIds.contains(r.id))
        .toList();

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  void recordSelection(String responseId) {
    _recentResponseIds.add(responseId);
    if (_recentResponseIds.length > _historyLimit) {
      _recentResponseIds.removeAt(0);
    }
  }

  void reset() {
    _recentResponseIds.clear();
  }
}
