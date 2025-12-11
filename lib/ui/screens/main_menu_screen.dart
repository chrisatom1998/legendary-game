import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Main menu screen - the entry point of the game.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI style
    SystemChrome.setSystemUIOverlayStyle(AppTheme.gameOverlayStyle);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundGradientTop,
              AppColors.backgroundGradientBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Game Title
                const Text(
                  'SKY',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    letterSpacing: 16,
                    height: 0.9,
                  ),
                ),
                const Text(
                  'TAPS',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                    letterSpacing: 8,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tap the falling shapes!',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(flex: 2),
                // Play Button
                GameButton(
                  text: 'PLAY',
                  icon: Icons.play_arrow,
                  onPressed: () => _navigateToGame(context),
                ),
                const SizedBox(height: 16),
                // Settings Button
                GameButton(
                  text: 'SETTINGS',
                  icon: Icons.settings,
                  isPrimary: false,
                  onPressed: () => _navigateToSettings(context),
                ),
                const Spacer(flex: 1),
                // Version info
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
