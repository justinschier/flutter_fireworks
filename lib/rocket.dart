import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' hide Timer;
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';

/// {@template rocket}
/// A [PositionComponent] that represents a rocket.
/// {@endtemplate}
class Rocket extends PositionComponent with HasGameRef<FireworksGame> {
  /// {@macro rocket}
  Rocket({
    required this.colors,
    required Color? rocketColor,
    required this.minExplosionDuration,
    required this.maxExplosionDuration,
    required this.minParticleCount,
    required this.maxParticleCount,
    required this.fadeOutDuration,
    Random? random,
  })  : rocketColor = rocketColor ?? Colors.pinkAccent,
        random = random ?? Random() {
    size = Vector2(4, 20);
    anchor = Anchor.center;
  }

  /// List of colors used for the fireworks explosions.
  final List<Color> colors;

  /// Color of the rocket trail.
  final Color rocketColor;

  /// Minimum duration for the explosion effect, in seconds.
  final double minExplosionDuration;

  /// Maximum duration for the explosion effect, in seconds.
  final double maxExplosionDuration;

  /// Minimum number of particles in the explosion.
  final int minParticleCount;

  /// Maximum number of particles in the explosion.
  final int maxParticleCount;

  /// Duration for particles to fade out, in seconds.
  final double fadeOutDuration;

  /// Random number generator for predictable randomness in tests.
  final Random random;

  late Paint paint;
  late Vector2 startPosition;
  late Vector2 targetPosition;
  double elapsedTime = 0;

  // Fields to store values for testing
  double? explosionDuration;
  double? adjustedFadeOutDuration;
  int? particleCount;

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Await the super.onLoad()

    paint = Paint()..color = rocketColor;

    final startX = gameRef.size.x * (0.2 + random.nextDouble() * 0.6);
    startPosition = Vector2(startX, gameRef.size.y);
    final xOffset = random.nextDouble() * 100 - 50;
    final targetX = (startX + xOffset).clamp(0.0, gameRef.size.x);
    final targetY = gameRef.size.y * (0.1 + random.nextDouble() * 0.4);

    targetPosition = Vector2(targetX, targetY);
    position = startPosition.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsedTime += dt;

    final t = (elapsedTime / 1.0).clamp(0.0, 1.0);

    final controlPointX = (startPosition.x + targetPosition.x) / 2;
    final controlPointY = (startPosition.y + targetPosition.y) / 2 - 100;
    final controlPoint = Vector2(controlPointX, controlPointY);

    position = quadraticBezier(startPosition, controlPoint, targetPosition, t);

    if (t >= 1.0) {
      explode();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    paint.color = rocketColor;
    canvas.drawRect(size.toRect(), paint);
  }

  /// Calculates a point along a quadratic Bezier curve at parameter [t].
  Vector2 quadraticBezier(Vector2 p0, Vector2 p1, Vector2 p2, double t) {
    final oneMinusT = 1 - t;
    return (p0 * oneMinusT * oneMinusT) +
        (p1 * 2 * oneMinusT * t) +
        (p2 * t * t);
  }

  /// Triggers the explosion of the rocket and returns the particle system.
  ParticleSystemComponent explode() {
    final color = colors[random.nextInt(colors.length)];
    explosionDuration = minExplosionDuration +
        random.nextDouble() * (maxExplosionDuration - minExplosionDuration);

    // Calculate fadeOutDuration as 20% of explosionDuration
    adjustedFadeOutDuration = explosionDuration! * 0.2;

    particleCount = random.nextInt(maxParticleCount - minParticleCount + 1) +
        minParticleCount;

    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        lifespan: explosionDuration!,
        count: particleCount!,
        generator: (i) {
          final theta = random.nextDouble() * 2 * pi;
          final speed = random.nextDouble() * 150 + 50;

          return FadingMovingParticle(
            lifespan: explosionDuration!,
            position: position.clone(),
            speed: Vector2(cos(theta) * speed, sin(theta) * speed),
            acceleration: Vector2(0, 100),
            radius: 3,
            baseColor: color,
            fadeOutDuration: adjustedFadeOutDuration!,
          );
        },
      ),
    );

    gameRef.add(particleComponent);
    return particleComponent;
  }
}
