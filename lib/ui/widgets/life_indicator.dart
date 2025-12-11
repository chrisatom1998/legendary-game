import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Displays remaining lives as heart icons.
class LifeIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;
  final double size;

  const LifeIndicator({
    super.key,
    required this.lives,
    this.maxLives = 3,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isActive = index < lives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Icon(
            isActive ? Icons.favorite : Icons.favorite_border,
            color: isActive ? AppColors.lifeActive : AppColors.lifeInactive,
            size: size,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        );
      }),
    );
  }
}
