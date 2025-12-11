import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized text style definitions for the entire app.
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // === Title Styles ===
  static const TextStyle gameTitle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 2.0,
    shadows: [
      Shadow(
        color: Colors.black26,
        offset: Offset(2, 2),
        blurRadius: 4,
      ),
    ],
  );

  static const TextStyle screenTitle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // === HUD Styles ===
  static const TextStyle score = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.scoreText,
    shadows: [
      Shadow(
        color: Colors.black45,
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static const TextStyle scoreLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle comboText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  // === Game Over Styles ===
  static const TextStyle gameOverTitle = TextStyle(
    fontSize: 42,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.5,
  );

  static const TextStyle finalScore = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  static const TextStyle highScoreLabel = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle newHighScore = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  // === Button Styles ===
  static const TextStyle buttonText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
    letterSpacing: 1.0,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );

  // === Settings Styles ===
  static const TextStyle settingsItem = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // === Points Popup ===
  static const TextStyle pointsPopup = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
    shadows: [
      Shadow(
        color: Colors.black45,
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );
}
