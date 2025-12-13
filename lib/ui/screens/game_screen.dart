import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../game/game.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// The main game screen where gameplay happens.
/// Features premium graphics, particle effects, and smooth animations.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  // Services
  final ScoreService _scoreService = ScoreService();
  final AudioService _audioService = AudioService();

  // Points popup management
  final List<PointsPopupData> _popups = [];
  int _popupIdCounter = 0;

  // Explosion particles management
  final List<ExplosionData> _explosions = [];
  int _explosionIdCounter = 0;

  // Track if this is a new high score
  bool _isNewHighScore = false;
  int _previousHighScore = 0;

  // Current combo count for display
  int _currentCombo = 0;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _loadHighScore();
    _setupCallbacks();
    _startGame();
  }

  Future<void> _loadHighScore() async {
    final highScore = await _scoreService.loadHighScore();
    _previousHighScore = highScore;
    _engine.setHighScore(highScore);
    if (mounted) setState(() {});
  }

  void _setupCallbacks() {
    _engine.onScore = (points, position) {
      _audioService.playTapSound();
      _currentCombo++;

      // Find the object that was just destroyed to get its color
      Color explosionColor = AppColors.primary;
      for (final obj in _engine.state.objects) {
        if (obj.isDestroyed && obj.destroyProgress < 0.1) {
          explosionColor = AppColors.getObjectColor(obj.colorIndex);
          break;
        }
      }

      setState(() {
        // Add points popup with combo info
        _popups.add(PointsPopupData(
          id: _popupIdCounter++,
          points: points,
          position: position,
          combo: _currentCombo,
        ));

        // Add explosion particles
        _explosions.add(ExplosionData(
          id: _explosionIdCounter++,
          position: position,
          color: explosionColor,
        ));
      });
    };

    _engine.onLifeLost = (remainingLives) {
      _audioService.playMissSound();
      _currentCombo = 0; // Reset combo on miss
    };

    _engine.onGameOver = (finalScore, highScore) {
      _audioService.playGameOverSound();
      _isNewHighScore = finalScore > _previousHighScore;
      if (_isNewHighScore) {
        _scoreService.saveHighScore(finalScore);
      }
    };
  }

  void _startGame() {
    _engine.startGame();
    _ticker = createTicker(_onTick);
    _ticker.start();
    _lastElapsed = Duration.zero;
    _currentCombo = 0;
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Cap dt to prevent huge jumps (e.g., when app was paused)
    final cappedDt = dt.clamp(0.0, 0.1);

    _engine.update(cappedDt);
    setState(() {});
  }

  void _handleTap(Offset position) {
    _engine.tapAt(position);
  }

  void _playAgain() {
    _isNewHighScore = false;
    _previousHighScore = _engine.state.highScore;
    _popups.clear();
    _explosions.clear();
    _startGame();
  }

  void _goToMainMenu() {
    Navigator.of(context).pop();
  }

  void _removePopup(int id) {
    setState(() {
      _popups.removeWhere((p) => p.id == id);
    });
  }

  void _removeExplosion(int id) {
    setState(() {
      _explosions.removeWhere((e) => e.id == id);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_engine.state.isPlaying,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _engine.state.isPlaying) {
          _goToMainMenu();
        }
      },
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Update engine with screen size
            _engine.setScreenSize(constraints.maxWidth, constraints.maxHeight);

            return Stack(
              children: [
                // Game canvas
                GameCanvas(
                  objects: _engine.state.objects,
                  onTap: _engine.state.isPlaying ? _handleTap : null,
                ),

                // HUD
                if (!_engine.state.isGameOver)
                  GameHUD(
                    score: _engine.state.score,
                    lives: _engine.state.lives,
                    maxLives: _engine.state.maxLives,
                    highScore: _engine.state.highScore,
                    combo: _currentCombo,
                  ),

                // Explosion particles
                ..._explosions.map((explosion) => ExplosionParticles(
                      key: ValueKey('explosion_${explosion.id}'),
                      position: explosion.position,
                      color: explosion.color,
                      onComplete: () => _removeExplosion(explosion.id),
                    )),

                // Points popups
                ..._popups.map((popup) => PointsPopup(
                      key: ValueKey('popup_${popup.id}'),
                      points: popup.points,
                      position: popup.position,
                      combo: popup.combo,
                      onComplete: () => _removePopup(popup.id),
                    )),

                // Game over overlay
                if (_engine.state.isGameOver)
                  GameOverOverlay(
                    score: _engine.state.score,
                    highScore: _engine.state.highScore,
                    isNewHighScore: _isNewHighScore,
                    onPlayAgain: _playAgain,
                    onMainMenu: _goToMainMenu,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
