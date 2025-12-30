// Game Data Models

enum Difficulty { easy, normal, hard }

enum Expression { normal, happy, shy, angry, confused }

enum TimingResult { perfect, good, miss }

class GameCharacter {
  final String id;
  final String name;
  final String description;
  final String color;
  final Map<String, Map<String, double>> weights;

  GameCharacter({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.weights,
  });

  factory GameCharacter.fromJson(Map<String, dynamic> json) {
    final weightsJson = json['weights'] as Map<String, dynamic>;
    final weights = <String, Map<String, double>>{};
    
    weightsJson.forEach((tag, typeWeights) {
      weights[tag] = Map<String, double>.from(
        (typeWeights as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      );
    });

    return GameCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      color: json['color'] as String,
      weights: weights,
    );
  }

  double getWeight(String promptTag, String responseType) {
    return weights[promptTag]?[responseType] ?? 1.0;
  }
}

class Prompt {
  final String id;
  final String tag;
  final String text;
  final List<String> recommend;

  Prompt({
    required this.id,
    required this.tag,
    required this.text,
    required this.recommend,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    return Prompt(
      id: json['id'] as String,
      tag: json['tag'] as String,
      text: json['text'] as String,
      recommend: List<String>.from(json['recommend'] as List),
    );
  }
}

class Response {
  final String id;
  final String type;
  final String text;
  final String fit;
  final String? forTag;

  Response({
    required this.id,
    required this.type,
    required this.text,
    required this.fit,
    this.forTag,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      fit: json['fit'] as String,
      forTag: json['forTag'] as String?,
    );
  }
}

class BGMInfo {
  final String id;
  final String name;
  final int bpm;
  final int duration;
  final String file;

  BGMInfo({
    required this.id,
    required this.name,
    required this.bpm,
    required this.duration,
    required this.file,
  });

  factory BGMInfo.fromJson(Map<String, dynamic> json) {
    return BGMInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      bpm: json['bpm'] as int,
      duration: json['duration'] as int,
      file: json['file'] as String,
    );
  }

  double get beatDuration => 60.0 / bpm;
  int get totalBeats => (duration / beatDuration).floor();
}

class GameData {
  final List<GameCharacter> characters;
  final List<Prompt> prompts;
  final List<Response> responseBank;
  final List<Response> mineResponses;
  final List<BGMInfo> bgmList;

  GameData({
    required this.characters,
    required this.prompts,
    required this.responseBank,
    required this.mineResponses,
    required this.bgmList,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      characters: (json['characters'] as List)
          .map((e) => GameCharacter.fromJson(e as Map<String, dynamic>))
          .toList(),
      prompts: (json['prompts'] as List)
          .map((e) => Prompt.fromJson(e as Map<String, dynamic>))
          .toList(),
      responseBank: (json['responseBank'] as List)
          .map((e) => Response.fromJson(e as Map<String, dynamic>))
          .toList(),
      mineResponses: (json['mineResponses'] as List)
          .map((e) => Response.fromJson(e as Map<String, dynamic>))
          .toList(),
      bgmList: (json['bgmList'] as List)
          .map((e) => BGMInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Choice {
  final Response response;
  final double weight;
  final bool isMine;

  Choice({
    required this.response,
    required this.weight,
    this.isMine = false,
  });
}

class BeatResult {
  final int beatNumber;
  final TimingResult timing;
  final Choice? selectedChoice;
  final double timingOffset;
  final int score;

  BeatResult({
    required this.beatNumber,
    required this.timing,
    this.selectedChoice,
    required this.timingOffset,
    required this.score,
  });
}

class GameScore {
  int totalScore = 0;
  int combo = 0;
  int maxCombo = 0;
  int perfectCount = 0;
  int goodCount = 0;
  int missCount = 0;
  double gauge = 50.0;
  final List<BeatResult> beatResults = [];

  void addResult(BeatResult result) {
    beatResults.add(result);
    
    int timingScore = 0;
    switch (result.timing) {
      case TimingResult.perfect:
        timingScore = 2;
        perfectCount++;
        combo++;
        break;
      case TimingResult.good:
        timingScore = 1;
        goodCount++;
        combo++;
        break;
      case TimingResult.miss:
        timingScore = 0;
        missCount++;
        combo = 0;
        break;
    }

    if (combo > maxCombo) maxCombo = combo;

    int fitScore = 0;
    if (result.selectedChoice != null) {
      switch (result.selectedChoice!.response.fit) {
        case 'good':
          fitScore = 2;
          gauge = (gauge + 5).clamp(0, 100);
          break;
        case 'neutral':
          fitScore = 0;
          break;
        case 'bad':
          fitScore = -2;
          gauge = (gauge - 10).clamp(0, 100);
          break;
      }
    }

    double comboMultiplier = 1.0 + (combo * 0.1);
    totalScore += ((timingScore + fitScore) * comboMultiplier).round();
  }

  String get rank {
    double ratio = (perfectCount + goodCount) / 
        (perfectCount + goodCount + missCount).clamp(1, double.infinity);
    if (ratio >= 0.95 && gauge >= 80) return 'S';
    if (ratio >= 0.85 && gauge >= 60) return 'A';
    if (ratio >= 0.70 && gauge >= 40) return 'B';
    if (ratio >= 0.50) return 'C';
    return 'D';
  }
}
