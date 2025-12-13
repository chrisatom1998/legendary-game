import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'services/services.dart';
import 'ui/screens/screens.dart';
import 'ui/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.gameOverlayStyle);

  // Initialize AdMob
  await AdService().initialize();

  runApp(const SkyTapsApp());
}

/// Main app widget for Sky Taps game.
class SkyTapsApp extends StatelessWidget {
  const SkyTapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sky Taps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainMenuScreen(),
    );
  }
}
