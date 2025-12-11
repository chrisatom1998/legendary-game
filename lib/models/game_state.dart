import 'game_object.dart';

/// Represents the current status of the game
enum GameStatus {
  /// Game is ready to start but hasn't begun
  ready,

  /// Game is actively running
  playing,

  /// Game is paused
  paused,

  /// Game has ended (player lost all lives)
  gameOver,
}

/// Represents the complete state of a game session.
/// This is a pure Dart class with no Flutter dependencies.
class GameState {
  /// All active game objects currently on screen
  final List<GameObject> objects;

  /// Current score
  int score;

  /// Current number of lives remaining
  int lives;

  /// Maximum lives at game start
  final int maxLives;

  /// Current game status
  GameStatus status;

  /// High score (persisted between sessions)
  int highScore;

  /// Time elapsed since game started (in seconds)
  double elapsedTime;

  /// Current difficulty multiplier (increases over time)
  double difficultyMultiplier;

  /// Counter for generating unique object IDs
  int _nextObjectId;

  GameState({
    List<GameObject>? objects,
    this.score = 0,
    this.lives = 3,
    this.maxLives = 3,
    this.status = GameStatus.ready,
    this.highScore = 0,
    this.elapsedTime = 0.0,
    this.difficultyMultiplier = 1.0,
    int nextObjectId = 0,
  })  : objects = objects ?? [],
        _nextObjectId = nextObjectId;

  /// Get the next unique object ID
  int getNextObjectId() => _nextObjectId++;

  /// Check if the game is currently active
  bool get isPlaying => status == GameStatus.playing;

  /// Check if the game is over
  bool get isGameOver => status == GameStatus.gameOver;

  /// Reset the game state for a new game
  void reset() {
    objects.clear();
    score = 0;
    lives = maxLives;
    status = GameStatus.ready;
    elapsedTime = 0.0;
    difficultyMultiplier = 1.0;
    _nextObjectId = 0;
  }

  /// Start the game
  void start() {
    reset();
    status = GameStatus.playing;
  }

  /// Pause the game
  void pause() {
    if (status == GameStatus.playing) {
      status = GameStatus.paused;
    }
  }

  /// Resume the game
  void resume() {
    if (status == GameStatus.paused) {
      status = GameStatus.playing;
    }
  }

  /// End the game
  void endGame() {
    status = GameStatus.gameOver;
    if (score > highScore) {
      highScore = score;
    }
  }

  /// Add points to the score
  void addScore(int points) {
    score += points;
    if (score > highScore) {
      highScore = score;
    }
  }

  /// Lose a life
  /// Returns true if the game should end (no lives remaining)
  bool loseLife() {
    lives--;
    if (lives <= 0) {
      lives = 0;
      endGame();
      return true;
    }
    return false;
  }

  /// Create a copy of this state
  GameState copyWith({
    List<GameObject>? objects,
    int? score,
    int? lives,
    int? maxLives,
    GameStatus? status,
    int? highScore,
    double? elapsedTime,
    double? difficultyMultiplier,
  }) {
    return GameState(
      objects: objects ?? List.from(this.objects),
      score: score ?? this.score,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      status: status ?? this.status,
      highScore: highScore ?? this.highScore,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
      nextObjectId: _nextObjectId,
    );
  }
}
