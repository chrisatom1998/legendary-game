import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app.
/// All hard-coded colors should be defined here.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // === Background Colors ===
  static const Color backgroundGradientTop = Color(0xFF1A237E);
  static const Color backgroundGradientBottom = Color(0xFF7C4DFF);
  static const Color menuBackground = Color(0xFF2C3E50);

  // === Primary UI Colors ===
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryDark = Color(0xFF5E35B1);
  static const Color accent = Color(0xFFFFD740);

  // === Text Colors ===
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textDark = Color(0xFF2C3E50);

  // === Game Object Colors (colorful flat palette) ===
  static const List<Color> objectColors = [
    Color(0xFFFF6B6B), // Coral Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFFFFE66D), // Yellow
    Color(0xFF95E1D3), // Mint
    Color(0xFFDDA0DD), // Plum
  ];

  // === Object Stroke Colors (darker versions) ===
  static const List<Color> objectStrokeColors = [
    Color(0xFFCC5555), // Dark Coral
    Color(0xFF3BA39B), // Dark Teal
    Color(0xFFCCB857), // Dark Yellow
    Color(0xFF77B8AA), // Dark Mint
    Color(0xFFB080B0), // Dark Plum
  ];

  // === Game UI Colors ===
  static const Color scoreText = Colors.white;
  static const Color lifeActive = Color(0xFFFF6B6B);
  static const Color lifeInactive = Color(0x4DFF6B6B); // 30% opacity

  // === Button Colors ===
  static const Color buttonPrimary = Color(0xFF7C4DFF);
  static const Color buttonPrimaryPressed = Color(0xFF5E35B1);
  static const Color buttonSecondary = Color(0xFF4ECDC4);
  static const Color buttonText = Colors.white;

  // === Overlay Colors ===
  static const Color overlayDark = Color(0xCC000000); // 80% black
  static const Color gameOverBackground = Color(0xE6000000); // 90% black

  // === Settings Screen ===
  static const Color settingsBackground = Color(0xFF1A1A2E);
  static const Color settingsTile = Color(0xFF16213E);
  static const Color switchActive = Color(0xFF7C4DFF);
  static const Color switchInactive = Color(0xFF4A4A4A);

  /// Get object color by index (safe, wraps around)
  static Color getObjectColor(int index) {
    return objectColors[index % objectColors.length];
  }

  /// Get object stroke color by index (safe, wraps around)
  static Color getObjectStrokeColor(int index) {
    return objectStrokeColors[index % objectStrokeColors.length];
  }
}
