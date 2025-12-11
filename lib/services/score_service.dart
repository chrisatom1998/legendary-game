import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting and loading high scores.
class ScoreService {
  static const String _highScoreKey = 'high_score';

  SharedPreferences? _prefs;

  /// Initialize the service (must be called before use)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load the high score from persistent storage
  Future<int> loadHighScore() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(_highScoreKey) ?? 0;
  }

  /// Save a new high score if it's higher than the current one
  /// Returns true if this was a new high score
  Future<bool> saveHighScore(int score) async {
    _prefs ??= await SharedPreferences.getInstance();

    final currentHighScore = _prefs!.getInt(_highScoreKey) ?? 0;
    if (score > currentHighScore) {
      await _prefs!.setInt(_highScoreKey, score);
      return true;
    }
    return false;
  }

  /// Reset the high score (for debugging/testing)
  Future<void> resetHighScore() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_highScoreKey);
  }
}
