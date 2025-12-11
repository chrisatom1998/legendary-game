/// Represents user-configurable game settings.
/// This is a pure Dart class with no Flutter dependencies.
class GameSettings {
  /// Whether sound effects are enabled
  bool soundEnabled;

  /// Whether background music is enabled
  bool musicEnabled;

  GameSettings({
    this.soundEnabled = true,
    this.musicEnabled = true,
  });

  /// Create a copy with optional parameter overrides
  GameSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
  }) {
    return GameSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
    );
  }

  /// Convert to a map for persistence
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
    };
  }

  /// Create from a map (for loading from persistence)
  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
    );
  }
}
