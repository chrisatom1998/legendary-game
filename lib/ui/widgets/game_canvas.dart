import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../theme/theme.dart';
import 'game_painter.dart';

/// The main game canvas widget that renders the game and handles input.
class GameCanvas extends StatelessWidget {
  final List<GameObject> objects;
  final void Function(Offset position)? onTap;

  const GameCanvas({
    super.key,
    required this.objects,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        onTap?.call(details.localPosition);
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientTop,
              AppColors.backgroundGradientBottom,
            ],
          ),
        ),
        child: CustomPaint(
          painter: GamePainter(objects: objects),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
