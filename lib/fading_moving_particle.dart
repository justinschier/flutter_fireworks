import 'dart:ui';

import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';

/// {@template fading_moving_particle}
/// A particle that fades out over time while moving.
/// {@endtemplate}
class FadingMovingParticle extends Particle {
  /// {@macro fading_moving_particle}
  FadingMovingParticle({
    required double lifespan,
    required this.position,
    required this.speed,
    required this.acceleration,
    required this.radius,
    required this.baseColor,
    required this.fadeOutDuration,
  }) : super(lifespan: lifespan);

  /// The position of the particle.
  final Vector2 position;

  /// The speed of the particle.
  final Vector2 speed;

  /// The acceleration of the particle.
  final Vector2 acceleration;

  /// The radius of the particle.
  final double radius;

  /// The base color of the particle.
  final Color baseColor;

  /// The duration of the fade out effect.
  final double fadeOutDuration;

  double _elapsed = 0.0;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    speed.add(acceleration * dt);
    position.add(speed * dt);
  }

  @override
  void render(Canvas canvas) {
    final remainingLife = lifespan - _elapsed;

    double opacity;

    if (remainingLife <= fadeOutDuration) {
      // Start fading out
      opacity = (remainingLife / fadeOutDuration).clamp(0.0, 1.0);
    } else {
      // Fully opaque
      opacity = 1.0;
    }

    final paint = Paint()
      ..color = baseColor.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position.toOffset(), radius, paint);
  }
}
