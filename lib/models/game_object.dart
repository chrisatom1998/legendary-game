import 'dart:ui';

/// Shape types for falling objects
enum ShapeType {
  circle,
  star,
  diamond,
}

/// Represents a falling object in the game.
/// This is a pure Dart class with no Flutter dependencies (except dart:ui for Offset).
class GameObject {
  /// Unique identifier for this object
  final int id;

  /// Shape type determines how the object is rendered
  final ShapeType shapeType;

  /// Color index (maps to theme colors)
  final int colorIndex;

  /// Current position (center of the object)
  Offset position;

  /// Size (diameter) of the object in logical pixels
  final double size;

  /// Vertical velocity in logical pixels per second
  double velocityY;

  /// Whether this object has been tapped and should be removed
  bool isDestroyed;

  /// Animation progress for destruction effect (0.0 to 1.0)
  double destroyProgress;

  GameObject({
    required this.id,
    required this.shapeType,
    required this.colorIndex,
    required this.position,
    this.size = 70.0,
    this.velocityY = 150.0,
    this.isDestroyed = false,
    this.destroyProgress = 0.0,
  });

  /// Returns the bounding rectangle for hit detection
  Rect get bounds => Rect.fromCenter(
        center: position,
        width: size,
        height: size,
      );

  /// Check if a tap at the given position hits this object
  bool containsPoint(Offset point) {
    final distance = (position - point).distance;
    return distance <= size / 2;
  }

  /// Update position based on velocity and delta time
  void update(double dt) {
    if (!isDestroyed) {
      position = Offset(position.dx, position.dy + velocityY * dt);
    } else {
      // Animate destruction
      destroyProgress += dt * 4.0; // Complete in ~0.25 seconds
    }
  }

  /// Create a copy with optional parameter overrides
  GameObject copyWith({
    int? id,
    ShapeType? shapeType,
    int? colorIndex,
    Offset? position,
    double? size,
    double? velocityY,
    bool? isDestroyed,
    double? destroyProgress,
  }) {
    return GameObject(
      id: id ?? this.id,
      shapeType: shapeType ?? this.shapeType,
      colorIndex: colorIndex ?? this.colorIndex,
      position: position ?? this.position,
      size: size ?? this.size,
      velocityY: velocityY ?? this.velocityY,
      isDestroyed: isDestroyed ?? this.isDestroyed,
      destroyProgress: destroyProgress ?? this.destroyProgress,
    );
  }
}
