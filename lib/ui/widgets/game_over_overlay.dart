import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../services/services.dart';
import '../theme/theme.dart';
import 'game_button.dart';

/// Premium overlay displayed when the game ends.
/// Features animated entrance, confetti, and glassmorphism.
class GameOverOverlay extends StatefulWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onMainMenu;
  final void Function(int bonusPoints)? onBonusEarned;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    this.isNewHighScore = false,
    this.onPlayAgain,
    this.onMainMenu,
    this.onBonusEarned,
  });

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;

  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;
  late Animation<double> _scaleTitle;
  late Animation<double> _scaleScore;
  late Animation<double> _buttonsFade;

  final List<_ConfettiParticle> _confetti = [];
  final _random = math.Random();

  final AdService _adService = AdService();
  bool _hasWatchedRewardedAd = false;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _slideUp = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _scaleTitle = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _scaleScore = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.4, 0.8, curve: Curves.elasticOut),
      ),
    );

    _buttonsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    if (widget.isNewHighScore) {
      _initConfetti();
      _confettiController.repeat();
    }

    _entranceController.forward();
  }

  void _initConfetti() {
    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiParticle(
        x: _random.nextDouble(),
        y: -_random.nextDouble() * 0.3,
        vx: (_random.nextDouble() - 0.5) * 0.3,
        vy: 0.2 + _random.nextDouble() * 0.3,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 5,
        size: 8 + _random.nextDouble() * 8,
        color: [
          AppColors.accent,
          AppColors.primary,
          AppColors.secondary,
          AppColors.particlePink,
          AppColors.particleCyan,
        ][_random.nextInt(5)],
      ));
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Container(
          color: AppColors.gameOverBackground.withValues(alpha: _fadeIn.value * 0.95),
          child: Stack(
            children: [
              // Confetti layer
              if (widget.isNewHighScore)
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _ConfettiPainter(
                        particles: _confetti,
                        time: _confettiController.value,
                      ),
                    );
                  },
                ),

              // Main content
              SafeArea(
                child: Center(
                  child: Transform.translate(
                    offset: Offset(0, _slideUp.value),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // GAME OVER title
                        Transform.scale(
                          scale: _scaleTitle.value,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                AppColors.textSecondary,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ).createShader(bounds),
                            child: const Text(
                              'GAME OVER',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Score display
                        Transform.scale(
                          scale: _scaleScore.value,
                          child: _buildScoreDisplay(),
                        ),
                        const SizedBox(height: 16),

                        // High score indicator
                        Opacity(
                          opacity: _scaleScore.value,
                          child: _buildHighScoreIndicator(),
                        ),
                        const SizedBox(height: 24),

                        // Rewarded ad button
                        if (_adService.isRewardedAdLoaded && !_hasWatchedRewardedAd)
                          Opacity(
                            opacity: _buttonsFade.value,
                            child: _buildRewardedAdButton(),
                          ),
                        const SizedBox(height: 24),

                        // Buttons
                        Opacity(
                          opacity: _buttonsFade.value,
                          child: Column(
                            children: [
                              GameButton(
                                text: 'PLAY AGAIN',
                                icon: Icons.replay_rounded,
                                onPressed: widget.onPlayAgain,
                              ),
                              const SizedBox(height: 16),
                              GameButton(
                                text: 'MAIN MENU',
                                icon: Icons.home_rounded,
                                isPrimary: false,
                                onPressed: widget.onMainMenu,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardedAdButton() {
    return GestureDetector(
      onTap: _showRewardedAd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.8),
              AppColors.secondary.withValues(alpha: 0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_circle_filled_rounded,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 10),
            const Text(
              'WATCH AD FOR +50 BONUS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardedAd() {
    _adService.showRewardedAd(
      onRewardEarned: (bonusPoints) {
        setState(() {
          _hasWatchedRewardedAd = true;
        });
        widget.onBonusEarned?.call(bonusPoints);
      },
      onAdNotAvailable: () {
        // Ad not available, could show a snackbar
        debugPrint('Rewarded ad not available');
      },
    );
  }

  Widget _buildScoreDisplay() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glowOpacity = widget.isNewHighScore
            ? 0.3 + _pulseController.value * 0.4
            : 0.2;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.glassMorphism,
                AppColors.glassMorphism.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: glowOpacity),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'SCORE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accentLight,
                    AppColors.accent,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: Text(
                  widget.score.toString(),
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: AppColors.accent,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighScoreIndicator() {
    if (widget.isNewHighScore) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + _pulseController.value * 0.05;
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accentLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'NEW HIGH SCORE!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.emoji_events_rounded,
          color: AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          'Best: ${widget.highScore}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double size;
  Color color;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double time;

  _ConfettiPainter({required this.particles, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = (particle.y + time * particle.vy) % 1.2;
      final x = particle.x + math.sin(time * 3 + particle.rotation) * 0.05;
      final rotation = particle.rotation + time * particle.rotationSpeed;

      if (y < 0 || y > 1.1) continue;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(rotation);

      // Draw rectangle confetti
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
