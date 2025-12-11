import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// A styled button for the game menus.
class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final bool isPrimary;
  final IconData? icon;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = 200,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? AppColors.buttonPrimary : AppColors.buttonSecondary,
          foregroundColor: AppColors.buttonText,
          elevation: 4,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24),
              const SizedBox(width: 8),
            ],
            Text(text, style: AppTextStyles.buttonText),
          ],
        ),
      ),
    );
  }
}

/// A smaller icon-only button for the game.
class GameIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;

  const GameIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: (color ?? AppColors.buttonPrimary).withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: (color ?? AppColors.buttonPrimary).withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
