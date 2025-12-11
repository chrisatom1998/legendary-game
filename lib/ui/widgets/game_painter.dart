import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../theme/theme.dart';

/// Custom painter that renders all game objects.
class GamePainter extends CustomPainter {
  final List<GameObject> objects;

  GamePainter({required this.objects});

  @override
  void paint(Canvas canvas, Size size) {
    for (final obj in objects) {
      _drawObject(canvas, obj);
    }
  }

  void _drawObject(Canvas canvas, GameObject obj) {
    final color = AppColors.getObjectColor(obj.colorIndex);
    final strokeColor = AppColors.getObjectStrokeColor(obj.colorIndex);

    // Apply destruction animation (scale down and fade out)
    double scale = 1.0;
    double opacity = 1.0;
    if (obj.isDestroyed) {
      scale = 1.0 + obj.destroyProgress * 0.3; // Grow slightly
      opacity = 1.0 - obj.destroyProgress; // Fade out
    }

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.save();
    canvas.translate(obj.position.dx, obj.position.dy);
    canvas.scale(scale);

    switch (obj.shapeType) {
      case ShapeType.circle:
        _drawCircle(canvas, obj.size / 2, paint, strokePaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, obj.size / 2, paint, strokePaint);
        break;
      case ShapeType.diamond:
        _drawDiamond(canvas, obj.size / 2, paint, strokePaint);
        break;
    }

    canvas.restore();
  }

  void _drawCircle(Canvas canvas, double radius, Paint fill, Paint stroke) {
    canvas.drawCircle(Offset.zero, radius, fill);
    canvas.drawCircle(Offset.zero, radius, stroke);
  }

  void _drawStar(Canvas canvas, double radius, Paint fill, Paint stroke) {
    final path = _createStarPath(radius, 5, 0.5);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawDiamond(Canvas canvas, double radius, Paint fill, Paint stroke) {
    final path = Path()
      ..moveTo(0, -radius)
      ..lineTo(radius * 0.7, 0)
      ..lineTo(0, radius)
      ..lineTo(-radius * 0.7, 0)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
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

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) {
    // Always repaint since objects move every frame
    return true;
  }
}
