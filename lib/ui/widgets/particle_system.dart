import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A single particle in the system
class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double maxLife;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.maxLife,
    required this.size,
    required this.color,
    this.rotation = 0,
    this.rotationSpeed = 0,
  });

  double get lifePercent => life / maxLife;

  void update(double dt) {
    x += vx * dt;
    y += vy * dt;
    vy += 200 * dt; // Gravity
    life -= dt;
    rotation += rotationSpeed * dt;
  }
}

/// Explosion particle effect when shapes are destroyed
class ExplosionParticles extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback? onComplete;

  const ExplosionParticles({
    super.key,
    required this.position,
    required this.color,
    this.onComplete,
  });

  @override
  State<ExplosionParticles> createState() => _ExplosionParticlesState();
}

class _ExplosionParticlesState extends State<ExplosionParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _initParticles();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.addListener(_update);
    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  void _initParticles() {
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi + _random.nextDouble() * 0.3;
      final speed = 150 + _random.nextDouble() * 200;
      final particleColors = [
        widget.color,
        widget.color.withValues(alpha: 0.8),
        AppColors.particleStar,
        AppColors.particleGold,
      ];

      _particles.add(Particle(
        x: 0,
        y: 0,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 100,
        life: 0.6 + _random.nextDouble() * 0.4,
        maxLife: 1.0,
        size: 4 + _random.nextDouble() * 8,
        color: particleColors[_random.nextInt(particleColors.length)],
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 10,
      ));
    }
  }

  double _lastValue = 0;

  void _update() {
    final dt = (_controller.value - _lastValue) * 0.8;
    _lastValue = _controller.value;

    for (final particle in _particles) {
      particle.update(dt);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: CustomPaint(
        size: const Size(200, 200),
        painter: ParticlePainter(particles: _particles),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.life <= 0) continue;

      final opacity = (particle.lifePercent).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);

      // Draw sparkle shape
      final path = Path();
      final s = particle.size * particle.lifePercent;
      path.moveTo(0, -s);
      path.lineTo(s * 0.3, 0);
      path.lineTo(0, s);
      path.lineTo(-s * 0.3, 0);
      path.close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

/// Data class to track explosion particles
class ExplosionData {
  final int id;
  final Offset position;
  final Color color;

  ExplosionData({
    required this.id,
    required this.position,
    required this.color,
  });
}
