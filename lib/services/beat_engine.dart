import 'dart:async';
import '../models/game_models.dart';

class BeatEngine {
  final BGMInfo bgmInfo;
  final void Function(int beatNumber, int beatInPhrase, int phraseNumber) onBeat;
  final void Function() onGameEnd;

  late final double _beatDuration;
  late final int _totalBeats;
  late final int _countInBeats;
  
  Stopwatch? _stopwatch;
  Timer? _beatTimer;
  int _currentBeat = -8; // Count-in starts at -8
  bool _isRunning = false;
  bool _isCountingIn = true;

  BeatEngine({
    required this.bgmInfo,
    required this.onBeat,
    required this.onGameEnd,
  }) {
    _beatDuration = bgmInfo.beatDuration;
    _totalBeats = bgmInfo.totalBeats;
    _countInBeats = 8; // 2 bars = 8 beats
  }

  double get beatDuration => _beatDuration;
  int get currentBeat => _currentBeat;
  bool get isRunning => _isRunning;
  bool get isCountingIn => _isCountingIn;

  void start() {
    if (_isRunning) return;
    
    _isRunning = true;
    _stopwatch = Stopwatch()..start();
    _schedulNextBeat();
  }

  void _schedulNextBeat() {
    if (!_isRunning) return;

    final elapsed = _stopwatch!.elapsedMilliseconds / 1000.0;
    final targetBeatTime = (_currentBeat + 1 + _countInBeats) * _beatDuration;
    final delay = (targetBeatTime - elapsed).clamp(0.0, _beatDuration);

    _beatTimer = Timer(Duration(milliseconds: (delay * 1000).round()), () {
      if (!_isRunning) return;

      _currentBeat++;
      
      if (_currentBeat >= 0) {
        _isCountingIn = false;
      }

      // Calculate phrase info
      final beatInPhrase = _currentBeat % 4;
      final phraseNumber = _currentBeat ~/ 4;

      onBeat(_currentBeat, beatInPhrase, phraseNumber);

      // Check if game should end
      if (_currentBeat >= _totalBeats) {
        stop();
        onGameEnd();
        return;
      }

      _schedulNextBeat();
    });
  }

  void stop() {
    _isRunning = false;
    _beatTimer?.cancel();
    _stopwatch?.stop();
  }

  void dispose() {
    stop();
  }

  /// Get the current elapsed time in seconds since game start
  double getElapsedTime() {
    if (_stopwatch == null) return 0;
    return _stopwatch!.elapsedMilliseconds / 1000.0;
  }

  /// Get the exact time of a specific beat
  double getBeatTime(int beatNumber) {
    return (beatNumber + _countInBeats) * _beatDuration;
  }

  /// Calculate timing result for an input
  TimingResult judgeTiming(double inputTime) {
    if (_currentBeat < 0) return TimingResult.miss;

    final currentBeatTime = getBeatTime(_currentBeat);
    final offset = (inputTime - currentBeatTime).abs() * 1000; // Convert to ms

    if (offset <= 80) return TimingResult.perfect;
    if (offset <= 160) return TimingResult.good;
    return TimingResult.miss;
  }

  /// Get timing offset in milliseconds from the nearest beat
  double getTimingOffset(double inputTime) {
    if (_currentBeat < 0) return 999;

    final currentBeatTime = getBeatTime(_currentBeat);
    return (inputTime - currentBeatTime) * 1000;
  }

  /// Get progress ratio for beat indicator animation (0.0 to 1.0)
  double getBeatProgress() {
    if (_stopwatch == null || !_isRunning) return 0;
    
    final elapsed = getElapsedTime();
    final currentBeatTime = getBeatTime(_currentBeat);
    final nextBeatTime = getBeatTime(_currentBeat + 1);
    
    final progress = (elapsed - currentBeatTime) / (nextBeatTime - currentBeatTime);
    return progress.clamp(0.0, 1.0);
  }
}
