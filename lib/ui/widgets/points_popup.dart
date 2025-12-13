import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Premium animated popup that shows points earned when tapping an object.
/// Features glow effects, color based on combo level, and smooth animations.
class PointsPopup extends StatefulWidget {
  final int points;
  final Offset position;
  final int combo;
  final VoidCallback? onComplete;

  const PointsPopup({
    super.key,
    required this.points,
    required this.position,
    this.combo = 1,
    this.onComplete,
  });

  @override
  State<PointsPopup> createState() => _PointsPopupState();
}

class _PointsPopupState extends State<PointsPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _offset;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 40,
      ),
    ]).animate(_controller);

    _offset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -70),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Slight rotation for higher combos
    final rotationAmount = widget.combo > 2 ? 0.05 : 0.0;
    _rotation = Tween<double>(
      begin: -rotationAmount,
      end: rotationAmount,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getComboColor(widget.combo);
    final isHighCombo = widget.combo >= 3;
    final fontSize = 24.0 + (widget.combo - 1) * 2.0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 50,
          top: widget.position.dy - 30 + _offset.value.dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Transform.rotate(
                angle: _rotation.value * math.pi,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.3),
                        color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: isHighCombo ? 20 : 10,
                        spreadRadius: isHighCombo ? 3 : 1,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Points text
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            color,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          '+${widget.points}',
                          style: TextStyle(
                            fontSize: fontSize.clamp(24.0, 36.0),
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: color,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Combo indicator for high combos
                      if (widget.combo > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flash_on_rounded,
                                size: 12,
                                color: color,
                              ),
                              Text(
                                '${widget.combo}x',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Data class to track a points popup
class PointsPopupData {
  final int id;
  final int points;
  final Offset position;
  final int combo;

  PointsPopupData({
    required this.id,
    required this.points,
    required this.position,
    this.combo = 1,
  });
}
