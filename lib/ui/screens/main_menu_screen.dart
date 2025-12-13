import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/services.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

/// Main menu screen - the entry point of the game.
/// Features animated title, floating shapes preview, and premium UI.
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _floatController;
  late AnimationController _pulseController;

  late Animation<double> _titleScale;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _buttonOpacity;

  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();

    // Title entrance animation
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _titleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // Floating animation for decorative elements
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Pulse animation for play button
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _titleController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(AppTheme.gameOverlayStyle);

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Floating decorative shapes
              _buildFloatingShapes(),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Animated Title
                    _buildTitle(),
                    const SizedBox(height: 24),
                    // Subtitle
                    _buildSubtitle(),
                    const Spacer(flex: 2),
                    // Buttons
                    _buildButtons(),
                    const Spacer(flex: 1),
                    // Version info
                    _buildVersionInfo(),
                    const SizedBox(height: 16),
                    // Banner Ad
                    _buildBannerAd(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    final adWidget = _adService.getBannerAdWidget();
    if (adWidget == null) {
      return const SizedBox(height: 50);
    }
    return Container(
      alignment: Alignment.center,
      width: _adService.bannerAdSize.width.toDouble(),
      height: _adService.bannerAdSize.height.toDouble(),
      child: adWidget,
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(6, (index) {
            final baseAngle = (index / 6) * math.pi * 2;
            final time = _floatController.value * math.pi * 2;
            final radius = 100.0 + index * 25;
            final size = 30.0 + index * 6;
            final opacity = 0.08 + (index * 0.015);

            // Create smooth orbital motion
            final x = math.cos(baseAngle + time * 0.3) * radius;
            final y = math.sin(baseAngle + time * 0.2) * radius * 0.6;

            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + x - size / 2,
              top: MediaQuery.of(context).size.height / 2 + y - size / 2,
              child: Transform.rotate(
                angle: time * (index.isEven ? 0.5 : -0.3),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.objectColors[index % AppColors.objectColors.length],
                          AppColors.objectColors[index % AppColors.objectColors.length]
                              .withValues(alpha: 0.5),
                        ],
                      ),
                      shape: index % 3 == 0
                          ? BoxShape.circle
                          : BoxShape.rectangle,
                      borderRadius: index % 3 != 0
                          ? BorderRadius.circular(size * 0.2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.objectColors[index % AppColors.objectColors.length]
                              .withValues(alpha: 0.4),
                          blurRadius: 25,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _titleController,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleScale.value,
          child: Opacity(
            opacity: _titleOpacity.value,
            child: Column(
              children: [
                // SKY text with gradient
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.textPrimary,
                      AppColors.textSecondary,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: const Text(
                    'SKY',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: 24,
                      height: 0.9,
                    ),
                  ),
                ),
                // TAPS text with gold gradient and glow
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accentLight,
                      AppColors.accent,
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: const Text(
                    'TAPS',
                    style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 12,
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: AppColors.accent,
                          blurRadius: 30,
                        ),
                        Shadow(
                          color: AppColors.accent,
                          blurRadius: 60,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return SlideTransition(
      position: _subtitleSlide,
      child: FadeTransition(
        opacity: _titleOpacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.glassMorphism,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Text(
            'Tap the falling shapes!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return FadeTransition(
      opacity: _buttonOpacity,
      child: Column(
        children: [
          // Animated Play Button with pulse
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + _pulseController.value * 0.02;
              final glowOpacity = 0.3 + _pulseController.value * 0.2;
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: glowOpacity),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              );
            },
            child: GameButton(
              text: 'PLAY',
              icon: Icons.play_arrow_rounded,
              onPressed: () => _navigateToGame(context),
            ),
          ),
          const SizedBox(height: 16),
          // Settings Button
          GameButton(
            text: 'SETTINGS',
            icon: Icons.settings_rounded,
            isPrimary: false,
            onPressed: () => _navigateToSettings(context),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return FadeTransition(
      opacity: _buttonOpacity,
      child: const Text(
        'v1.0.0',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
          letterSpacing: 2,
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
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SettingsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
