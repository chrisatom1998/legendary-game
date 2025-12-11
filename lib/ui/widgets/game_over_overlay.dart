import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'game_button.dart';

/// Overlay displayed when the game ends.
class GameOverOverlay extends StatelessWidget {
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onMainMenu;

  const GameOverOverlay({
    super.key,
    required this.score,
    required this.highScore,
    this.isNewHighScore = false,
    this.onPlayAgain,
    this.onMainMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gameOverBackground,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: AppTextStyles.gameOverTitle,
              ),
              const SizedBox(height: 32),
              Text(
                score.toString(),
                style: AppTextStyles.finalScore,
              ),
              const SizedBox(height: 8),
              if (isNewHighScore)
                const Text(
                  'NEW HIGH SCORE!',
                  style: AppTextStyles.newHighScore,
                )
              else
                Text(
                  'Best: $highScore',
                  style: AppTextStyles.highScoreLabel,
                ),
              const SizedBox(height: 48),
              GameButton(
                text: 'PLAY AGAIN',
                icon: Icons.replay,
                onPressed: onPlayAgain,
              ),
              const SizedBox(height: 16),
              GameButton(
                text: 'MAIN MENU',
                icon: Icons.home,
                isPrimary: false,
                onPressed: onMainMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
