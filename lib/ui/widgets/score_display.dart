import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Displays the current score with optional label.
class ScoreDisplay extends StatelessWidget {
  final int score;
  final String label;
  final bool showLabel;

  const ScoreDisplay({
    super.key,
    required this.score,
    this.label = 'SCORE',
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: AppTextStyles.scoreLabel,
          ),
        Text(
          score.toString().padLeft(6, '0'),
          style: AppTextStyles.score,
        ),
      ],
    );
  }
}
