import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Service for persisting and loading game settings.
class SettingsService {
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';

  SharedPreferences? _prefs;

  /// Initialize the service (must be called before use)
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Load settings from persistent storage
  Future<GameSettings> loadSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    return GameSettings(
      soundEnabled: _prefs!.getBool(_soundEnabledKey) ?? true,
      musicEnabled: _prefs!.getBool(_musicEnabledKey) ?? true,
    );
  }

  /// Save settings to persistent storage
  Future<void> saveSettings(GameSettings settings) async {
    _prefs ??= await SharedPreferences.getInstance();

    await Future.wait([
      _prefs!.setBool(_soundEnabledKey, settings.soundEnabled),
      _prefs!.setBool(_musicEnabledKey, settings.musicEnabled),
    ]);
  }

  /// Update a single setting
  Future<void> setSoundEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_soundEnabledKey, enabled);
  }

  /// Update a single setting
  Future<void> setMusicEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_musicEnabledKey, enabled);
  }
}
