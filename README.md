# Sky Taps

A simple, addictive tap-based mobile game built with Flutter where players tap falling shapes before they hit the bottom of the screen.

## Screenshots

<p align="center">
  <img src="screenshots/main_menu.svg" width="200" alt="Main Menu">
  <img src="screenshots/gameplay.svg" width="200" alt="Gameplay">
  <img src="screenshots/game_over.svg" width="200" alt="Game Over">
</p>

<p align="center">
  <img src="screenshots/settings.svg" width="200" alt="Settings">
</p>

## Features

- **Simple Gameplay**: Tap falling shapes before they reach the bottom
- **Multiple Shape Types**: Circles, squares, triangles, diamonds, and hexagons
- **Colorful Design**: Vibrant flat color palette with smooth gradients
- **Combo System**: Score bonus points for quick successive taps
- **Progressive Difficulty**: Game gets faster as you play
- **High Score Tracking**: Persistent high score storage
- **Lives System**: 3 lives per game
- **Settings**: Toggle sound effects and background music
- **Smooth Animations**: Points popup animations and destroy effects

## How to Play

1. Tap **PLAY** from the main menu to start the game
2. Tap the falling shapes before they reach the bottom of the screen
3. Each shape is worth **10 points** + combo bonuses
4. Miss a shape and you lose a life
5. Lose all 3 lives and it's game over
6. Try to beat your high score!

## Game Mechanics

| Feature | Description |
|---------|-------------|
| Base Points | 10 points per tap |
| Combo Bonus | +5 points for each successive quick tap |
| Starting Lives | 3 |
| Difficulty | Increases over time (up to 3x speed) |

## Project Structure

```
lib/
├── main.dart              # App entry point
├── game/
│   ├── game.dart          # Game exports
│   └── game_engine.dart   # Core game logic
├── models/
│   ├── game_object.dart   # Falling shape model
│   ├── game_settings.dart # Settings model
│   ├── game_state.dart    # Game state management
│   └── models.dart        # Model exports
├── services/
│   ├── audio_service.dart    # Sound playback
│   ├── score_service.dart    # High score persistence
│   ├── settings_service.dart # Settings persistence
│   └── services.dart         # Service exports
└── ui/
    ├── screens/
    │   ├── game_screen.dart      # Main gameplay screen
    │   ├── main_menu_screen.dart # Start menu
    │   └── settings_screen.dart  # Settings page
    ├── theme/
    │   ├── app_colors.dart      # Color definitions
    │   ├── app_text_styles.dart # Typography
    │   └── app_theme.dart       # Theme configuration
    └── widgets/
        ├── game_button.dart      # Reusable button
        ├── game_canvas.dart      # Game rendering surface
        ├── game_hud.dart         # Score and lives display
        ├── game_over_overlay.dart # End game screen
        ├── game_painter.dart     # Custom shape rendering
        ├── life_indicator.dart   # Heart icons
        ├── points_popup.dart     # Score animation
        └── score_display.dart    # Score text
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd legendary-game
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Running Tests

```bash
flutter test
```

## Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **shared_preferences** - Local storage for high scores and settings

## Color Palette

The game features a vibrant, modern color scheme:

| Color | Hex | Usage |
|-------|-----|-------|
| Deep Indigo | `#1A237E` | Background gradient top |
| Purple | `#7C4DFF` | Background gradient bottom, buttons |
| Gold | `#FFD740` | Accent, highlights |
| Coral Red | `#FF6B6B` | Shape color, lives |
| Teal | `#4ECDC4` | Shape color, secondary buttons |
| Yellow | `#FFE66D` | Shape color |
| Mint | `#95E1D3` | Shape color |
| Plum | `#DDA0DD` | Shape color |

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
