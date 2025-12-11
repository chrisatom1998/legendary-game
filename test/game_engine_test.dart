import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sky_taps/game/game_engine.dart';
import 'package:sky_taps/models/models.dart';

void main() {
  group('GameEngine', () {
    late GameEngine engine;
    late Random mockRandom;

    setUp(() {
      // Use a seeded random for predictable tests
      mockRandom = Random(42);
      engine = GameEngine(
        config: const GameConfig(
          screenWidth: 400,
          screenHeight: 800,
          baseSpawnInterval: 0.5,
          objectSize: 70,
        ),
        random: mockRandom,
      );
    });

    group('Game lifecycle', () {
      test('should start with ready status', () {
        expect(engine.state.status, equals(GameStatus.ready));
        expect(engine.state.score, equals(0));
        expect(engine.state.lives, equals(3));
      });

      test('should transition to playing when startGame is called', () {
        engine.startGame();
        expect(engine.state.status, equals(GameStatus.playing));
        expect(engine.state.isPlaying, isTrue);
      });

      test('should pause and resume correctly', () {
        engine.startGame();
        expect(engine.state.isPlaying, isTrue);

        engine.pauseGame();
        expect(engine.state.status, equals(GameStatus.paused));
        expect(engine.state.isPlaying, isFalse);

        engine.resumeGame();
        expect(engine.state.status, equals(GameStatus.playing));
        expect(engine.state.isPlaying, isTrue);
      });

      test('should reset state when starting new game', () {
        engine.startGame();
        engine.state.score = 100;
        engine.state.lives = 1;

        engine.startGame(); // Start new game

        expect(engine.state.score, equals(0));
        expect(engine.state.lives, equals(3));
        expect(engine.state.objects, isEmpty);
      });
    });

    group('Object spawning', () {
      test('should spawn objects after spawn interval', () {
        engine.startGame();
        expect(engine.state.objects, isEmpty);

        // Update for just under the spawn interval
        engine.update(0.4);
        expect(engine.state.objects, isEmpty);

        // Update to pass the spawn interval
        engine.update(0.2);
        expect(engine.state.objects.length, equals(1));
      });

      test('should spawn objects at top of screen', () {
        engine.startGame();
        engine.update(0.6); // Trigger spawn

        final obj = engine.state.objects.first;
        expect(obj.position.dy, lessThan(0)); // Spawned above screen
      });

      test('should spawn objects within screen bounds', () {
        engine.startGame();

        // Spawn multiple objects
        for (int i = 0; i < 10; i++) {
          engine.update(0.6);
        }

        for (final obj in engine.state.objects) {
          expect(obj.position.dx, greaterThanOrEqualTo(50)); // spawnMargin
          expect(obj.position.dx, lessThanOrEqualTo(350)); // screenWidth - margin
        }
      });

      test('should assign unique IDs to objects', () {
        engine.startGame();
        engine.update(0.6);
        engine.update(0.6);

        final ids = engine.state.objects.map((o) => o.id).toSet();
        expect(ids.length, equals(engine.state.objects.length));
      });
    });

    group('Object movement', () {
      test('should move objects downward on update', () {
        engine.startGame();
        engine.update(0.6); // Spawn an object

        final initialY = engine.state.objects.first.position.dy;
        engine.update(0.1);
        final newY = engine.state.objects.first.position.dy;

        expect(newY, greaterThan(initialY));
      });

      test('should not update objects when paused', () {
        engine.startGame();
        engine.update(0.6); // Spawn an object

        final initialY = engine.state.objects.first.position.dy;
        engine.pauseGame();
        engine.update(1.0); // Try to update while paused

        expect(engine.state.objects.first.position.dy, equals(initialY));
      });
    });

    group('Tap detection and scoring', () {
      test('should remove object and add score when tapped', () {
        engine.startGame();
        engine.update(0.6); // Spawn an object

        final obj = engine.state.objects.first;
        final hit = engine.tapAt(obj.position);

        expect(hit, isTrue);
        expect(obj.isDestroyed, isTrue);
        expect(engine.state.score, equals(10)); // basePoints
      });

      test('should not detect tap on empty area', () {
        engine.startGame();
        engine.update(0.6); // Spawn an object

        // Tap far away from the object
        final hit = engine.tapAt(const Offset(1000, 1000));

        expect(hit, isFalse);
        expect(engine.state.score, equals(0));
      });

      test('should award combo bonus for quick successive taps', () {
        engine.startGame();

        // Spawn multiple objects
        engine.update(0.6);
        engine.update(0.6);

        final obj1 = engine.state.objects[0];
        final obj2 = engine.state.objects[1];

        // Tap both quickly
        engine.tapAt(obj1.position);
        engine.tapAt(obj2.position);

        // First tap: 10 points, Second tap: 10 + 5 (combo) = 15
        expect(engine.state.score, equals(25));
      });

      test('should reset combo after delay', () {
        engine.startGame();
        engine.update(0.6);

        final obj1 = engine.state.objects.first;
        engine.tapAt(obj1.position);
        expect(engine.state.score, equals(10));

        // Wait for combo to reset
        engine.update(1.1);
        engine.update(0.6); // Spawn new object

        final obj2 = engine.state.objects.firstWhere((o) => !o.isDestroyed);
        engine.tapAt(obj2.position);

        // Should be base points again (no combo)
        expect(engine.state.score, equals(20));
      });

      test('should not allow tapping when game is not playing', () {
        engine.startGame();
        engine.update(0.6);

        final obj = engine.state.objects.first;
        engine.pauseGame();
        final hit = engine.tapAt(obj.position);

        expect(hit, isFalse);
        expect(engine.state.score, equals(0));
      });
    });

    group('Missed objects and lives', () {
      test('should lose life when object reaches bottom', () {
        engine.startGame();
        engine.update(0.6); // Spawn object

        // Move object to bottom (simulate many updates)
        for (int i = 0; i < 100; i++) {
          engine.update(0.1);
        }

        expect(engine.state.lives, lessThan(3));
      });

      test('should end game when all lives are lost', () {
        engine.startGame();

        // Lose all lives by letting objects fall
        int iterations = 0;
        while (!engine.state.isGameOver && iterations < 1000) {
          engine.update(0.1);
          iterations++;
        }

        expect(engine.state.isGameOver, isTrue);
        expect(engine.state.lives, equals(0));
      });

      test('should trigger onLifeLost callback', () {
        int callbackLives = -1;
        engine.onLifeLost = (lives) {
          callbackLives = lives;
        };

        engine.startGame();
        engine.update(0.6); // Spawn

        // Let object fall to bottom
        for (int i = 0; i < 100; i++) {
          engine.update(0.1);
        }

        expect(callbackLives, isNot(-1));
      });

      test('should trigger onGameOver callback', () {
        int finalScore = -1;
        engine.onGameOver = (score, highScore) {
          finalScore = score;
        };

        engine.startGame();

        // Lose all lives
        int iterations = 0;
        while (!engine.state.isGameOver && iterations < 1000) {
          engine.update(0.1);
          iterations++;
        }

        expect(finalScore, isNot(-1));
      });
    });

    group('High score', () {
      test('should update high score when score exceeds it', () {
        engine.setHighScore(50);
        engine.startGame();

        // Score enough points
        for (int i = 0; i < 10; i++) {
          engine.update(0.6);
          final obj = engine.state.objects.lastWhere((o) => !o.isDestroyed);
          engine.tapAt(obj.position);
        }

        expect(engine.state.highScore, greaterThan(50));
      });

      test('should preserve high score when game ends with lower score', () {
        engine.setHighScore(1000);
        engine.startGame();
        engine.state.endGame();

        expect(engine.state.highScore, equals(1000));
      });
    });

    group('Difficulty scaling', () {
      test('should increase difficulty over time', () {
        engine.startGame();
        final initialMultiplier = engine.state.difficultyMultiplier;

        // Simulate time passing
        for (int i = 0; i < 100; i++) {
          engine.update(0.1);
        }

        expect(engine.state.difficultyMultiplier, greaterThan(initialMultiplier));
      });

      test('should cap difficulty multiplier at maximum', () {
        engine.startGame();

        // Simulate a long game
        for (int i = 0; i < 10000; i++) {
          engine.update(0.1);
          // Tap any objects to prevent game over
          for (final obj in engine.state.objects.where((o) => !o.isDestroyed)) {
            engine.tapAt(obj.position);
          }
        }

        expect(engine.state.difficultyMultiplier, lessThanOrEqualTo(3.0));
      });
    });
  });

  group('GameObject', () {
    test('should detect point inside bounds', () {
      final obj = GameObject(
        id: 1,
        shapeType: ShapeType.circle,
        colorIndex: 0,
        position: const Offset(100, 100),
        size: 70,
      );

      expect(obj.containsPoint(const Offset(100, 100)), isTrue); // Center
      expect(obj.containsPoint(const Offset(120, 100)), isTrue); // Inside
      expect(obj.containsPoint(const Offset(200, 200)), isFalse); // Outside
    });

    test('should update position based on velocity', () {
      final obj = GameObject(
        id: 1,
        shapeType: ShapeType.circle,
        colorIndex: 0,
        position: const Offset(100, 100),
        velocityY: 100,
      );

      obj.update(0.5); // Half second
      expect(obj.position.dy, equals(150)); // 100 + (100 * 0.5)
    });

    test('should not move when destroyed', () {
      final obj = GameObject(
        id: 1,
        shapeType: ShapeType.circle,
        colorIndex: 0,
        position: const Offset(100, 100),
        velocityY: 100,
        isDestroyed: true,
      );

      obj.update(0.5);
      expect(obj.position.dy, equals(100)); // Unchanged
    });
  });

  group('GameState', () {
    test('should start with default values', () {
      final state = GameState();
      expect(state.score, equals(0));
      expect(state.lives, equals(3));
      expect(state.status, equals(GameStatus.ready));
    });

    test('should generate unique object IDs', () {
      final state = GameState();
      final id1 = state.getNextObjectId();
      final id2 = state.getNextObjectId();
      expect(id1, isNot(id2));
    });

    test('should properly reset state', () {
      final state = GameState();
      state.score = 500;
      state.lives = 1;
      state.status = GameStatus.playing;

      state.reset();

      expect(state.score, equals(0));
      expect(state.lives, equals(3));
      expect(state.status, equals(GameStatus.ready));
    });
  });
}
