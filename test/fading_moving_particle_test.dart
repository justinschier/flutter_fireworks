import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FadingMovingParticle Tests', () {
    test('Initialization', () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2(0, 0),
        speed: Vector2(10, 15),
        acceleration: Vector2(0, -9.8),
        radius: 5.0,
        baseColor: Colors.blue,
        fadeOutDuration: 0.5,
      );

      expect(particle.lifespan, 2.0);
      expect(particle.position, Vector2(0, 0));
      expect(particle.speed, Vector2(10, 15));
      expect(particle.acceleration, Vector2(0, -9.8));
      expect(particle.radius, 5.0);
      expect(particle.baseColor, Colors.blue);
      expect(particle.fadeOutDuration, 0.5);
    });

    test('Update Position and Speed', () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2.zero(),
        speed: Vector2(10, 15),
        acceleration: Vector2(0, -9.8),
        radius: 5.0,
        baseColor: Colors.green,
        fadeOutDuration: 0.5,
      );

      // Simulate update for 1 second
      particle.update(1.0);

      // Expected speed after 1 second: initial speed + acceleration * dt
      final expectedSpeed = Vector2(10, 15) + Vector2(0, -9.8) * 1.0;
      expect(particle.speed.x, closeTo(expectedSpeed.x, 1e-6));
      expect(particle.speed.y, closeTo(expectedSpeed.y, 1e-6));

      // Expected position after 1 second: position += updated speed * dt
      final expectedPosition = Vector2(0, 0) + particle.speed * 1.0;
      expect(particle.position.x, closeTo(expectedPosition.x, 1e-6));
      expect(particle.position.y, closeTo(expectedPosition.y, 1e-6));
    });

    test(
        'Opacity Calculation during Fade Out when remainingLife == fadeOutDuration',
        () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2.zero(),
        speed: Vector2(10, 10),
        acceleration: Vector2.zero(),
        radius: 5.0,
        baseColor: Colors.red,
        fadeOutDuration: 0.5,
      );

      // Update the particle to reach the point where remainingLife == fadeOutDuration
      particle.update(1.5); // _elapsed = 1.5, remainingLife = 0.5

      final recordingCanvas = RecordingCanvas();

      particle.render(recordingCanvas);

      // Check the opacity
      final drawCircleCalls = recordingCanvas.drawCircleCalls;
      expect(drawCircleCalls.length, 1);

      final drawCircleCall = drawCircleCalls.first;
      final paintUsed = drawCircleCall.paint;
      expect(paintUsed.color.a, closeTo(1.0, 1e-6),
          reason:
              'Opacity should be 1.0 when remainingLife == fadeOutDuration');
    });

    test(
        'Opacity Calculation during Fade Out when remainingLife < fadeOutDuration',
        () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2.zero(),
        speed: Vector2(10, 10),
        acceleration: Vector2.zero(),
        radius: 5.0,
        baseColor: Colors.yellow,
        fadeOutDuration: 0.5,
      );

      // Update the particle to reach the point where remainingLife < fadeOutDuration
      particle.update(1.6); // _elapsed = 1.6, remainingLife = 0.4

      final recordingCanvas = RecordingCanvas();

      particle.render(recordingCanvas);

      // Check the opacity
      final drawCircleCalls = recordingCanvas.drawCircleCalls;
      expect(drawCircleCalls.length, 1);

      final drawCircleCall = drawCircleCalls.first;
      final paintUsed = drawCircleCall.paint;
      final expectedOpacity = (0.4 / 0.5).clamp(0.0, 1.0);
      expect(paintUsed.color.a, closeTo(expectedOpacity, 1e-6),
          reason:
              'Opacity should be proportional to remainingLife / fadeOutDuration');
    });

    test('Opacity Calculation when remainingLife > fadeOutDuration', () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2.zero(),
        speed: Vector2(10, 10),
        acceleration: Vector2.zero(),
        radius: 5.0,
        baseColor: Colors.purple,
        fadeOutDuration: 0.5,
      );

      // Update the particle to a point where remainingLife > fadeOutDuration
      particle.update(1.0); // _elapsed = 1.0, remainingLife = 1.0

      final recordingCanvas = RecordingCanvas();

      particle.render(recordingCanvas);

      // Check the opacity
      final drawCircleCalls = recordingCanvas.drawCircleCalls;
      expect(drawCircleCalls.length, 1);

      final drawCircleCall = drawCircleCalls.first;
      final paintUsed = drawCircleCall.paint;
      expect(paintUsed.color.a, equals(1.0),
          reason: 'Opacity should be 1.0 when remainingLife > fadeOutDuration');
    });

    test('Particle expired', () {
      final particle = FadingMovingParticle(
        lifespan: 2.0,
        position: Vector2.zero(),
        speed: Vector2(10, 10),
        acceleration: Vector2.zero(),
        radius: 5.0,
        baseColor: Colors.orange,
        fadeOutDuration: 0.5,
      );

      // Update the particle beyond its lifespan
      particle.update(2.1); // _elapsed = 2.1, remainingLife = -0.1

      expect(particle.shouldRemove, isTrue,
          reason: 'Particle should be expired after its lifespan');
    });
  });
}

/// A simple recording canvas to capture drawing calls for testing purposes.
class RecordingCanvas implements Canvas {
  List<DrawCircleCall> drawCircleCalls = [];

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    drawCircleCalls.add(DrawCircleCall(c, radius, paint));
  }

  // Implement other Canvas methods as no-ops or throw UnimplementedError
  @override
  void noSuchMethod(Invocation invocation) {}
}

class DrawCircleCall {
  final Offset c;
  final double radius;
  final Paint paint;

  DrawCircleCall(this.c, this.radius, this.paint);
}
