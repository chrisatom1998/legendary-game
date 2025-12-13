import 'dart:math';
import 'dart:ui';

import '../models/models.dart';

/// Configuration for the game engine
class GameConfig {
  /// Screen width in logical pixels
  final double screenWidth;

  /// Screen height in logical pixels
  final double screenHeight;

  /// Base points awarded per tap
  final int basePoints;

  /// Bonus points for quick successive taps
  final int comboBonus;

  /// Base spawn interval in seconds
  final double baseSpawnInterval;

  /// Minimum spawn interval (at max difficulty)
  final double minSpawnInterval;

  /// Base fall velocity in pixels per second
  final double baseVelocity;

  /// Maximum fall velocity
  final double maxVelocity;

  /// How much difficulty increases per second
  final double difficultyRampRate;

  /// Object size
  final double objectSize;

  /// Margin from screen edges for spawning
  final double spawnMargin;

  const GameConfig({
    this.screenWidth = 400.0,
    this.screenHeight = 800.0,
    this.basePoints = 10,
    this.comboBonus = 5,
    this.baseSpawnInterval = 1.5,
    this.minSpawnInterval = 0.4,
    this.baseVelocity = 150.0,
    this.maxVelocity = 400.0,
    this.difficultyRampRate = 0.02,
    this.objectSize = 70.0,
    this.spawnMargin = 50.0,
  });

  /// Create a config with updated screen dimensions
  GameConfig withScreenSize(double width, double height) {
    return GameConfig(
      screenWidth: width,
      screenHeight: height,
      basePoints: basePoints,
      comboBonus: comboBonus,
      baseSpawnInterval: baseSpawnInterval,
      minSpawnInterval: minSpawnInterval,
      baseVelocity: baseVelocity,
      maxVelocity: maxVelocity,
      difficultyRampRate: difficultyRampRate,
      objectSize: objectSize,
      spawnMargin: spawnMargin,
    );
  }
}

/// Callback types for game events
typedef OnScoreCallback = void Function(int points, Offset position);
typedef OnLifeLostCallback = void Function(int remainingLives);
typedef OnGameOverCallback = void Function(int finalScore, int highScore);

/// The core game engine - handles all game logic.
/// This is a pure Dart class with minimal dependencies.
class GameEngine {
  /// Current game state
  final GameState state;

  /// Game configuration
  GameConfig config;

  /// Random number generator for spawning
  final Random _random;

  /// Time since last spawn
  double _timeSinceLastSpawn;

  /// Time since last tap (for combo detection)
  double _timeSinceLastTap;

  /// Current combo count
  int _comboCount;

  /// Event callbacks
  OnScoreCallback? onScore;
  OnLifeLostCallback? onLifeLost;
  OnGameOverCallback? onGameOver;

  GameEngine({
    GameState? state,
    GameConfig? config,
    Random? random,
  })  : state = state ?? GameState(),
        config = config ?? const GameConfig(),
        _random = random ?? Random(),
        _timeSinceLastSpawn = 0.0,
        _timeSinceLastTap = 10.0,
        _comboCount = 0;

  /// Update screen dimensions (call when screen size changes)
  void setScreenSize(double width, double height) {
    config = config.withScreenSize(width, height);
  }

  /// Start a new game
  void startGame() {
    state.start();
    _timeSinceLastSpawn = 0.0;
    _timeSinceLastTap = 10.0;
    _comboCount = 0;
  }

  /// Pause the game
  void pauseGame() {
    state.pause();
  }

  /// Resume the game
  void resumeGame() {
    state.resume();
  }

  /// Main update loop - call this every frame
  /// [dt] is the delta time in seconds since last update
  void update(double dt) {
    if (!state.isPlaying) return;

    // Update elapsed time and difficulty
    state.elapsedTime += dt;
    _updateDifficulty();

    // Update combo timer
    _timeSinceLastTap += dt;
    if (_timeSinceLastTap > 1.0) {
      _comboCount = 0;
    }

    // Update spawn timer and spawn new objects
    _timeSinceLastSpawn += dt;
    if (_timeSinceLastSpawn >= _currentSpawnInterval) {
      _spawnObject();
      _timeSinceLastSpawn = 0.0;
    }

    // Update all objects
    _updateObjects(dt);

    // Check for missed objects (reached bottom)
    _checkMissedObjects();

    // Remove destroyed objects that finished animating
    state.objects.removeWhere(
      (obj) => obj.isDestroyed && obj.destroyProgress >= 1.0,
    );
  }

  /// Handle a tap at the given position
  /// Returns true if an object was hit
  bool tapAt(Offset position) {
    if (!state.isPlaying) return false;

    // Find the first object that contains this point
    // Check from front to back (last added = on top)
    for (int i = state.objects.length - 1; i >= 0; i--) {
      final obj = state.objects[i];
      if (!obj.isDestroyed && obj.containsPoint(position)) {
        // Hit!
        obj.isDestroyed = true;

        // Calculate points with combo bonus
        _comboCount++;
        _timeSinceLastTap = 0.0;
        final points = config.basePoints + (_comboCount - 1) * config.comboBonus;
        state.addScore(points);

        // Trigger callback
        onScore?.call(points, obj.position);

        return true;
      }
    }

    return false;
  }

  /// Update difficulty based on elapsed time
  void _updateDifficulty() {
    // Difficulty increases over time, capped at 3x
    state.difficultyMultiplier = 1.0 + (state.elapsedTime * config.difficultyRampRate);
    if (state.difficultyMultiplier > 3.0) {
      state.difficultyMultiplier = 3.0;
    }
  }

  /// Get current spawn interval based on difficulty
  double get _currentSpawnInterval {
    final interval = config.baseSpawnInterval / state.difficultyMultiplier;
    return interval.clamp(config.minSpawnInterval, config.baseSpawnInterval);
  }

  /// Get current velocity based on difficulty
  double get _currentVelocity {
    final velocity = config.baseVelocity * state.difficultyMultiplier;
    return velocity.clamp(config.baseVelocity, config.maxVelocity);
  }

  /// Spawn a new falling object
  void _spawnObject() {
    // Random x position within margins
    final minX = config.spawnMargin;
    final maxX = config.screenWidth - config.spawnMargin;
    final x = minX + _random.nextDouble() * (maxX - minX);

    // Random shape and color
    final shapeType = ShapeType.values[_random.nextInt(ShapeType.values.length)];
    final colorIndex = _random.nextInt(7); // 7 colors available

    final obj = GameObject(
      id: state.getNextObjectId(),
      shapeType: shapeType,
      colorIndex: colorIndex,
      position: Offset(x, -config.objectSize / 2),
      size: config.objectSize,
      velocityY: _currentVelocity,
    );

    state.objects.add(obj);
  }

  /// Update all object positions
  void _updateObjects(double dt) {
    for (final obj in state.objects) {
      obj.update(dt);
    }
  }

  /// Check for objects that reached the bottom (missed)
  void _checkMissedObjects() {
    final bottomThreshold = config.screenHeight + config.objectSize / 2;

    for (final obj in state.objects) {
      if (!obj.isDestroyed && obj.position.dy >= bottomThreshold) {
        // Missed this object
        obj.isDestroyed = true;
        obj.destroyProgress = 1.0; // Skip animation, remove immediately

        final gameEnded = state.loseLife();
        onLifeLost?.call(state.lives);

        if (gameEnded) {
          onGameOver?.call(state.score, state.highScore);
        }
      }
    }
  }

  /// Set the high score (loaded from persistence)
  void setHighScore(int highScore) {
    state.highScore = highScore;
  }
}
