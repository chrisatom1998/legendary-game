import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A floating star/particle in the background
class BackgroundStar {
  double x;
  double y;
  double size;
  double opacity;
  double twinkleSpeed;
  double twinkleOffset;
  double driftSpeed;
  Color color;

  BackgroundStar({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.twinkleSpeed,
    required this.twinkleOffset,
    required this.driftSpeed,
    required this.color,
  });
}

/// Animated background with floating stars and gradient
class AnimatedBackground extends StatefulWidget {
  final Widget? child;
  final bool enableAnimation;

  const AnimatedBackground({
    super.key,
    this.child,
    this.enableAnimation = true,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<BackgroundStar> _stars = [];
  final _random = math.Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    if (widget.enableAnimation) {
      _controller.repeat();
    }
  }

  void _initStars(Size size) {
    if (_initialized) return;
    _initialized = true;

    final starColors = [
      AppColors.particleStar,
      AppColors.particleCyan,
      AppColors.particlePurple,
      AppColors.particlePink,
      AppColors.particleGold,
    ];

    // Create background stars
    for (int i = 0; i < 50; i++) {
      _stars.add(BackgroundStar(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        size: 1 + _random.nextDouble() * 3,
        opacity: 0.2 + _random.nextDouble() * 0.5,
        twinkleSpeed: 0.5 + _random.nextDouble() * 2,
        twinkleOffset: _random.nextDouble() * math.pi * 2,
        driftSpeed: 5 + _random.nextDouble() * 15,
        color: starColors[_random.nextInt(starColors.length)],
      ));
    }

    // Add some larger glowing orbs
    for (int i = 0; i < 8; i++) {
      _stars.add(BackgroundStar(
        x: _random.nextDouble() * size.width,
        y: _random.nextDouble() * size.height,
        size: 20 + _random.nextDouble() * 40,
        opacity: 0.03 + _random.nextDouble() * 0.05,
        twinkleSpeed: 0.2 + _random.nextDouble() * 0.3,
        twinkleOffset: _random.nextDouble() * math.pi * 2,
        driftSpeed: 2 + _random.nextDouble() * 5,
        color: starColors[_random.nextInt(starColors.length)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initStars(size);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: Stack(
                children: [
                  // Background stars layer
                  CustomPaint(
                    size: size,
                    painter: BackgroundPainter(
                      stars: _stars,
                      time: _controller.value * 10,
                      screenHeight: size.height,
                    ),
                  ),
                  // Vignette overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Child content
                  if (widget.child != null) widget.child!,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final List<BackgroundStar> stars;
  final double time;
  final double screenHeight;

  BackgroundPainter({
    required this.stars,
    required this.time,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final star in stars) {
      // Calculate twinkle
      final twinkle = 0.5 + 0.5 * math.sin(time * star.twinkleSpeed + star.twinkleOffset);
      final opacity = (star.opacity * twinkle).clamp(0.0, 1.0);

      // Calculate drift (slow downward movement that wraps)
      final y = (star.y + time * star.driftSpeed) % screenHeight;

      if (star.size > 10) {
        // Large glowing orb
        final paint = Paint()
          ..color = star.color.withValues(alpha: opacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, star.size * 0.5);
        canvas.drawCircle(Offset(star.x, y), star.size, paint);
      } else {
        // Small twinkling star
        final paint = Paint()
          ..color = star.color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;

        // Draw star shape
        final path = Path();
        final s = star.size * (0.8 + twinkle * 0.4);
        path.moveTo(star.x, y - s);
        path.lineTo(star.x + s * 0.3, y);
        path.lineTo(star.x, y + s);
        path.lineTo(star.x - s * 0.3, y);
        path.close();

        canvas.drawPath(path, paint);

        // Add glow for brighter stars
        if (star.opacity > 0.4) {
          final glowPaint = Paint()
            ..color = star.color.withValues(alpha: opacity * 0.3)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
          canvas.drawCircle(Offset(star.x, y), star.size * 2, glowPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
