import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rocket Tests', () {
    test('Rocket Initialization', () {
      final rocket = Rocket(
        colors: [Colors.red, Colors.blue],
        rocketColor: Colors.pinkAccent,
        minExplosionDuration: 1.0,
        maxExplosionDuration: 2.0,
        minParticleCount: 10,
        maxParticleCount: 20,
        fadeOutDuration: 0.5,
      );

      expect(rocket.size, Vector2(4, 20));
      expect(rocket.anchor, Anchor.center);
      expect(rocket.colors, [Colors.red, Colors.blue]);
      expect(rocket.rocketColor, Colors.pinkAccent);
      expect(rocket.minExplosionDuration, 1.0);
      expect(rocket.maxExplosionDuration, 2.0);
      expect(rocket.minParticleCount, 10);
      expect(rocket.maxParticleCount, 20);
      expect(rocket.fadeOutDuration, 0.5);
      expect(rocket.elapsedTime, 0.0); // Ensure initialization starts at 0
    });

    testWithGame<FireworksGame>(
      'Rocket Movement',
      () => FireworksGame(),
      (game) async {
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 10,
          maxParticleCount: 20,
          fadeOutDuration: 0.5,
        );

        await game.ensureAdd(rocket);

        // Validate initial state
        expect(rocket.elapsedTime, equals(0.0),
            reason: 'Elapsed time should start at 0.');

        // Simulate time progression
        for (int i = 0; i < 10; i++) {
          game.update(0.1); // Incremental updates
        }

        // Process pending lifecycle events
        game.update(0);

        // Process game updates until the rocket is removed or max iterations reached
        int iterations = 0;
        while (game.children.contains(rocket) && iterations < 10) {
          game.update(0.1);
          iterations++;
        }

        // Validate updated state
        expect(rocket.elapsedTime, greaterThanOrEqualTo(1.0),
            reason: 'Elapsed time should be at least 1.0 after updates.');
        expect(rocket.position.y, lessThan(rocket.startPosition.y),
            reason: 'Rocket should have moved upwards.');
        expect(game.children.contains(rocket), isFalse,
            reason: 'Rocket should be removed after explosion.');
      },
    );

    testWithGame<FireworksGame>(
      'Rocket Explosion',
      () => FireworksGame(),
      (game) async {
        final random = Random(0); // Fixed seed for predictability
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 1.0,
          minParticleCount: 10,
          maxParticleCount: 10,
          fadeOutDuration: 0.5,
          random: random,
        );

        await game.ensureAdd(rocket);

        // Trigger explosion
        rocket.elapsedTime = 1.0;
        game.update(0.1); // Process update to trigger explosion
        game.update(0); // Process pending lifecycle events

        // Validate that the rocket is removed
        expect(game.children.contains(rocket), isFalse,
            reason: 'Rocket should be removed after explosion.');

        // Validate explosion
        final particles = game.children.whereType<ParticleSystemComponent>();
        expect(particles.length, equals(1),
            reason: 'There should be exactly one particle system.');

        // Use the stored particle count from the rocket
        expect(
          rocket.particleCount,
          equals(10),
          reason: 'Particle count should match expected value.',
        );
      },
    );

    testWithGame<FireworksGame>(
      'Rocket Rendering',
      () => FireworksGame(),
      (game) async {
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 10,
          maxParticleCount: 20,
          fadeOutDuration: 0.5,
        );

        await game.ensureAdd(rocket);

        // Render to a canvas and verify paint color
        final recorder = PictureRecorder();
        final canvas = Canvas(recorder);
        game.render(canvas);
        final picture = recorder.endRecording();

        expect(rocket.paint.color.value, rocket.rocketColor.value);

        // Dispose of the picture
        picture.dispose();
      },
    );

    testWithGame<FireworksGame>(
      'Quadratic Bezier Calculation',
      () => FireworksGame(),
      (game) async {
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 10,
          maxParticleCount: 20,
          fadeOutDuration: 0.5,
        );

        await game.ensureAdd(rocket);

        final p0 = Vector2(0, 0);
        final p1 = Vector2(50, -100);
        final p2 = Vector2(100, 0);

        final result = rocket.quadraticBezier(p0, p1, p2, 0.5);

        // Validate bezier point is at expected position
        expect(result.x, closeTo(50.0, 1e-6));
        expect(result.y, closeTo(-50.0, 1e-6));
      },
    );

    testWithGame<FireworksGame>(
      'Rocket Removal Before Explosion',
      () => FireworksGame(),
      (game) async {
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 10,
          maxParticleCount: 20,
          fadeOutDuration: 0.5,
        );

        await game.ensureAdd(rocket);

        // Simulate time progression but not enough to trigger explosion
        for (int i = 0; i < 5; i++) {
          game.update(0.1); // Total elapsed time: 0.5s
        }

        // Remove the rocket before it explodes
        await game.ensureRemove(rocket);
        game.update(0); // Process pending lifecycle events

        // Validate that rocket is removed
        expect(game.children.contains(rocket), isFalse,
            reason: 'Rocket should be removed before explosion.');

        // Ensure no particles were added
        final particles = game.children.whereType<ParticleSystemComponent>();
        expect(particles.isEmpty, isTrue,
            reason: 'No particles should be added.');
      },
    );

    testWithGame<FireworksGame>(
      'Explosion Timing Edge Case',
      () => FireworksGame(),
      (game) async {
        final random = Random(0); // Fixed seed for predictability
        final rocket = Rocket(
          colors: [Colors.red, Colors.blue],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 1.0,
          maxExplosionDuration: 1.0,
          minParticleCount: 10,
          maxParticleCount: 10,
          fadeOutDuration: 0.5,
          random: random,
        );

        await game.ensureAdd(rocket);

        // Simulate time progression to just before explosion
        for (int i = 0; i < 9; i++) {
          game.update(0.1); // Total elapsed time: 0.9s
        }

        // Validate that rocket has not exploded yet
        expect(game.children.contains(rocket), isTrue,
            reason: 'Rocket should still be in the game.');

        // Update to reach explosion time
        game.update(0.1); // Total elapsed time: 1.0s

        // Process pending lifecycle events
        game.update(0);

        // Process game updates until the rocket is removed or max iterations reached
        int iterations = 0;
        while (game.children.contains(rocket) && iterations < 10) {
          game.update(0.1);
          iterations++;
        }

        // Validate that rocket has exploded and been removed
        expect(game.children.contains(rocket), isFalse,
            reason: 'Rocket should have exploded and been removed.');

        // Validate that particles have been added
        final particles = game.children.whereType<ParticleSystemComponent>();
        expect(particles.length, equals(1),
            reason: 'Particles should have been added upon explosion.');
      },
    );

    testWithGame<FireworksGame>(
      'Fade Out Duration Calculation',
      () => FireworksGame(),
      (game) async {
        final random = Random(0);
        final rocket = Rocket(
          colors: [Colors.red],
          rocketColor: Colors.pinkAccent,
          minExplosionDuration: 2.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 10,
          maxParticleCount: 10,
          fadeOutDuration: 0.5,
          random: random,
        );

        await game.ensureAdd(rocket);

        // Trigger explosion
        rocket.elapsedTime = 1.0;
        game.update(0.1);
        game.update(0);

        // Validate that the rocket is removed
        expect(game.children.contains(rocket), isFalse,
            reason: 'Rocket should be removed after explosion.');

        // Validate explosion
        final particles = game.children.whereType<ParticleSystemComponent>();
        expect(particles.length, equals(1),
            reason: 'There should be exactly one particle system.');

        // Use the stored adjustedFadeOutDuration from the rocket
        final expectedFadeOutDuration = 0.4; // 20% of 2.0

        expect(
          rocket.adjustedFadeOutDuration,
          closeTo(expectedFadeOutDuration, 1e-6),
          reason: 'Fade out duration should be 20% of explosion duration.',
        );
      },
    );
  });
}
