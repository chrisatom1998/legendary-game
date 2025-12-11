import 'package:flutter/material.dart';

import 'life_indicator.dart';
import 'score_display.dart';

/// Head-up display showing score, lives, and high score during gameplay.
class GameHUD extends StatelessWidget {
  final int score;
  final int lives;
  final int maxLives;
  final int highScore;
  final VoidCallback? onPause;

  const GameHUD({
    super.key,
    required this.score,
    required this.lives,
    this.maxLives = 3,
    this.highScore = 0,
    this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score on the left
            ScoreDisplay(score: score),
            // Lives on the right
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LifeIndicator(lives: lives, maxLives: maxLives),
                const SizedBox(height: 4),
                if (highScore > 0)
                  Text(
                    'BEST: $highScore',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
