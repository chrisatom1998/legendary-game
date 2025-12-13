import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../theme/theme.dart';

/// Custom painter that renders all game objects with premium graphics.
/// Features glow effects, gradients, and smooth animations.
class GamePainter extends CustomPainter {
  final List<GameObject> objects;

  GamePainter({required this.objects});

  @override
  void paint(Canvas canvas, Size size) {
    // First pass: Draw all glows (behind shapes)
    for (final obj in objects) {
      _drawGlow(canvas, obj);
    }

    // Second pass: Draw all shapes
    for (final obj in objects) {
      _drawObject(canvas, obj);
    }
  }

  void _drawGlow(Canvas canvas, GameObject obj) {
    if (obj.isDestroyed && obj.destroyProgress > 0.5) return;

    final glowColor = AppColors.getObjectGlowColor(obj.colorIndex);
    final glowOpacity = obj.isDestroyed ? (1.0 - obj.destroyProgress) * 0.4 : 0.4;
    final glowRadius = obj.size * 0.8;

    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: glowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.save();
    canvas.translate(obj.position.dx, obj.position.dy);

    // Pulsing glow effect
    final pulseScale = 1.0 + math.sin(obj.id * 0.5 + obj.position.dy * 0.01) * 0.1;

    canvas.drawCircle(Offset.zero, glowRadius * pulseScale, glowPaint);
    canvas.restore();
  }

  void _drawObject(Canvas canvas, GameObject obj) {
    final color = AppColors.getObjectColor(obj.colorIndex);
    final strokeColor = AppColors.getObjectStrokeColor(obj.colorIndex);
    final innerColor = AppColors.getObjectInnerColor(obj.colorIndex);

    // Apply destruction animation
    double scale = 1.0;
    double opacity = 1.0;
    double rotation = 0.0;
    if (obj.isDestroyed) {
      scale = 1.0 + obj.destroyProgress * 0.5;
      opacity = 1.0 - obj.destroyProgress;
      rotation = obj.destroyProgress * math.pi * 0.5;
    }

    canvas.save();
    canvas.translate(obj.position.dx, obj.position.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    // Create gradient for premium look
    final gradient = ui.Gradient.radial(
      Offset(-obj.size * 0.2, -obj.size * 0.2),
      obj.size * 0.8,
      [
        strokeColor.withValues(alpha: opacity),
        color.withValues(alpha: opacity),
        innerColor.withValues(alpha: opacity),
      ],
      [0.0, 0.4, 1.0],
    );

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: opacity * 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Inner highlight paint
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    switch (obj.shapeType) {
      case ShapeType.circle:
        _drawCircle(canvas, obj.size / 2, fillPaint, strokePaint, highlightPaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, obj.size / 2, fillPaint, strokePaint, highlightPaint);
        break;
      case ShapeType.diamond:
        _drawDiamond(canvas, obj.size / 2, fillPaint, strokePaint, highlightPaint);
        break;
      case ShapeType.hexagon:
        _drawHexagon(canvas, obj.size / 2, fillPaint, strokePaint, highlightPaint);
        break;
      case ShapeType.pentagon:
        _drawPentagon(canvas, obj.size / 2, fillPaint, strokePaint, highlightPaint);
        break;
    }

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, double radius, Paint fill, Paint stroke, Paint highlight) {
    // Main circle
    canvas.drawCircle(Offset.zero, radius, fill);
    canvas.drawCircle(Offset.zero, radius, stroke);

    // Inner shine arc
    final shinePath = Path()
      ..addArc(
        Rect.fromCircle(center: Offset.zero, radius: radius * 0.7),
        -math.pi * 0.75,
        math.pi * 0.5,
      );
    canvas.drawPath(shinePath, highlight);
  }

  void _drawStar(Canvas canvas, double radius, Paint fill, Paint stroke, Paint highlight) {
    final path = _createStarPath(radius, 5, 0.45);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Small inner star highlight
    final innerPath = _createStarPath(radius * 0.4, 5, 0.45);
    canvas.drawPath(innerPath, highlight);
  }

  void _drawDiamond(Canvas canvas, double radius, Paint fill, Paint stroke, Paint highlight) {
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.65, 0)
      ..lineTo(0, radius)
      ..lineTo(-radius * 0.65, 0)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Shine line on diamond
    final shineLine = Path()
      ..moveTo(-radius * 0.2, -radius * 0.5)
      ..lineTo(-radius * 0.4, 0);
    canvas.drawPath(shineLine, highlight);
  }

  void _drawHexagon(Canvas canvas, double radius, Paint fill, Paint stroke, Paint highlight) {
    final path = _createPolygonPath(radius, 6);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Inner hexagon highlight
    final innerPath = _createPolygonPath(radius * 0.5, 6);
    canvas.drawPath(innerPath, highlight);
  }

  void _drawPentagon(Canvas canvas, double radius, Paint fill, Paint stroke, Paint highlight) {
    final path = _createPolygonPath(radius, 5);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);

    // Inner highlight
    final innerPath = _createPolygonPath(radius * 0.45, 5);
    canvas.drawPath(innerPath, highlight);
  }

  Path _createStarPath(double radius, int points, double innerRadiusRatio) {
    final path = Path();
    final innerRadius = radius * innerRadiusRatio;
    final angleStep = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = i * angleStep - math.pi / 2;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _createPolygonPath(double radius, int sides) {
    final path = Path();
    final angleStep = (2 * math.pi) / sides;

    for (int i = 0; i < sides; i++) {
      final angle = i * angleStep - math.pi / 2;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    return true;
  }
}
