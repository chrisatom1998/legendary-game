import 'package:flutter/material.dart';

/// Centralized color definitions for the entire app.
/// Production-ready color palette with premium visual effects.
class AppColors {
  // Prevent instantiation
  AppColors._();

  // === Background Colors (Rich gradient palette) ===
  static const Color backgroundGradientTop = Color(0xFF0D0D1A);
  static const Color backgroundGradientMiddle = Color(0xFF1A1A3E);
  static const Color backgroundGradientBottom = Color(0xFF2D1B4E);
  static const Color menuBackground = Color(0xFF0A0A14);

  // === Primary UI Colors ===
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color accent = Color(0xFFFBBF24);
  static const Color accentLight = Color(0xFFFDE68A);

  // === Secondary Colors ===
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);

  // === Text Colors ===
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // 70% white
  static const Color textMuted = Color(0x80FFFFFF); // 50% white
  static const Color textDark = Color(0xFF1F2937);

  // === Game Object Colors (Vibrant neon palette with glow support) ===
  static const List<Color> objectColors = [
    Color(0xFFFF6B9D), // Hot Pink
    Color(0xFF00F5D4), // Cyan
    Color(0xFFFFE55C), // Gold
    Color(0xFF9B5DE5), // Purple
    Color(0xFF00BBF9), // Electric Blue
    Color(0xFFF15BB5), // Magenta
    Color(0xFF7ED321), // Lime
  ];

  // === Object Glow Colors (Outer glow for premium look) ===
  static const List<Color> objectGlowColors = [
    Color(0xFFFF6B9D), // Hot Pink glow
    Color(0xFF00F5D4), // Cyan glow
    Color(0xFFFFE55C), // Gold glow
    Color(0xFF9B5DE5), // Purple glow
    Color(0xFF00BBF9), // Electric Blue glow
    Color(0xFFF15BB5), // Magenta glow
    Color(0xFF7ED321), // Lime glow
  ];

  // === Object Stroke Colors (Lighter highlight versions) ===
  static const List<Color> objectStrokeColors = [
    Color(0xFFFFB8D0), // Light Pink
    Color(0xFF80FAE8), // Light Cyan
    Color(0xFFFFF0A3), // Light Gold
    Color(0xFFCDB4F0), // Light Purple
    Color(0xFF80DDFC), // Light Blue
    Color(0xFFF9ADD8), // Light Magenta
    Color(0xFFB8E986), // Light Lime
  ];

  // === Object Inner Colors (Darker core for depth) ===
  static const List<Color> objectInnerColors = [
    Color(0xFFCC4470), // Dark Pink
    Color(0xFF00C4A8), // Dark Cyan
    Color(0xFFCCB647), // Dark Gold
    Color(0xFF7B4AB8), // Dark Purple
    Color(0xFF0096C7), // Dark Blue
    Color(0xFFC14891), // Dark Magenta
    Color(0xFF64A91A), // Dark Lime
  ];

  // === Game UI Colors ===
  static const Color scoreText = Colors.white;
  static const Color lifeActive = Color(0xFFEF4444);
  static const Color lifeInactive = Color(0x40EF4444);
  static const Color lifePulse = Color(0xFFFF6B6B);

  // === Button Colors (Premium gradient buttons) ===
  static const Color buttonPrimaryStart = Color(0xFF8B5CF6);
  static const Color buttonPrimaryEnd = Color(0xFF6366F1);
  static const Color buttonPrimary = Color(0xFF7C3AED);
  static const Color buttonPrimaryPressed = Color(0xFF5B21B6);
  static const Color buttonSecondaryStart = Color(0xFF06B6D4);
  static const Color buttonSecondaryEnd = Color(0xFF0891B2);
  static const Color buttonSecondary = Color(0xFF06B6D4);
  static const Color buttonText = Colors.white;
  static const Color buttonGlow = Color(0x408B5CF6);

  // === Overlay Colors ===
  static const Color overlayDark = Color(0xCC000000);
  static const Color gameOverBackground = Color(0xF0050510);
  static const Color glassMorphism = Color(0x20FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // === Settings Screen ===
  static const Color settingsBackground = Color(0xFF0A0A14);
  static const Color settingsTile = Color(0xFF141428);
  static const Color settingsTileHover = Color(0xFF1A1A3E);
  static const Color switchActive = Color(0xFF8B5CF6);
  static const Color switchInactive = Color(0xFF374151);
  static const Color switchTrack = Color(0xFF1F2937);

  // === Particle/Effect Colors ===
  static const Color particleStar = Color(0xFFFFFFFF);
  static const Color particleGold = Color(0xFFFBBF24);
  static const Color particlePink = Color(0xFFF472B6);
  static const Color particleCyan = Color(0xFF22D3EE);
  static const Color particlePurple = Color(0xFFA78BFA);

  // === Combo Colors (for streak indicators) ===
  static const List<Color> comboColors = [
    Color(0xFFFFFFFF), // 1x - White
    Color(0xFF22D3EE), // 2x - Cyan
    Color(0xFF8B5CF6), // 3x - Purple
    Color(0xFFF472B6), // 4x - Pink
    Color(0xFFFBBF24), // 5x+ - Gold
  ];

  /// Background gradient for game canvas
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundGradientTop,
      backgroundGradientMiddle,
      backgroundGradientBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Premium button gradient
  static const LinearGradient buttonPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [buttonPrimaryStart, buttonPrimaryEnd],
  );

  static const LinearGradient buttonSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryDark],
  );

  /// Get object color by index (safe, wraps around)
  static Color getObjectColor(int index) {
    return objectColors[index % objectColors.length];
  }

  /// Get object stroke color by index (safe, wraps around)
  static Color getObjectStrokeColor(int index) {
    return objectStrokeColors[index % objectStrokeColors.length];
  }

  /// Get object glow color by index (safe, wraps around)
  static Color getObjectGlowColor(int index) {
    return objectGlowColors[index % objectGlowColors.length];
  }

  /// Get object inner color by index (safe, wraps around)
  static Color getObjectInnerColor(int index) {
    return objectInnerColors[index % objectInnerColors.length];
  }

  /// Get combo color based on streak count
  static Color getComboColor(int combo) {
    if (combo <= 1) return comboColors[0];
    if (combo <= 2) return comboColors[1];
    if (combo <= 3) return comboColors[2];
    if (combo <= 4) return comboColors[3];
    return comboColors[4];
  }
}
