import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Displays remaining lives as animated heart icons.
/// Features pulse animation and glow effects.
class LifeIndicator extends StatefulWidget {
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
  State<LifeIndicator> createState() => _LifeIndicatorState();
}

class _LifeIndicatorState extends State<LifeIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _previousLives = 0;

  @override
  void initState() {
    super.initState();
    _previousLives = widget.lives;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(LifeIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _previousLives = widget.lives;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxLives, (index) {
        final isActive = index < widget.lives;
        final isLastActive = index == widget.lives - 1 && widget.lives > 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: _AnimatedHeart(
            isActive: isActive,
            isLastActive: isLastActive,
            size: widget.size,
            animation: _pulseController,
            index: index,
          ),
        );
      }),
    );
  }
}

class _AnimatedHeart extends StatelessWidget {
  final bool isActive;
  final bool isLastActive;
  final double size;
  final Animation<double> animation;
  final int index;

  const _AnimatedHeart({
    required this.isActive,
    required this.isLastActive,
    required this.size,
    required this.animation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) {
      // Inactive heart - simple greyed out
      return Icon(
        Icons.favorite_rounded,
        color: AppColors.lifeInactive,
        size: size,
      );
    }

    // Active heart with animations
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pulse = isLastActive
            ? 1.0 + math.sin(animation.value * math.pi) * 0.12
            : 1.0;

        final glow = isLastActive
            ? 0.4 + animation.value * 0.3
            : 0.3;

        return Transform.scale(
          scale: pulse,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lifeActive.withValues(alpha: glow),
                  blurRadius: isLastActive ? 12 : 6,
                  spreadRadius: isLastActive ? 2 : 0,
                ),
              ],
            ),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lifePulse,
                  AppColors.lifeActive,
                ],
              ).createShader(bounds),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: size,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
