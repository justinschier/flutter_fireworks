import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FireworksGame Tests', () {
    test('Background Color', () {
      final game = FireworksGame();
      expect(game.backgroundColor(), equals(Colors.transparent));
    });

    testWithGame<FireworksGame>(
      'Launch Rocket',
      () => FireworksGame(),
      (game) async {
        // Define rocket parameters
        final colors = [Colors.red, Colors.blue];
        final rocketColor = Colors.pinkAccent;
        final minExplosionDuration = 1.0;
        final maxExplosionDuration = 2.0;
        final minParticleCount = 10;
        final maxParticleCount = 20;
        final fadeOutDuration = 0.5;

        // Launch the rocket
        game.launchRocket(
          colors: colors,
          rocketColor: rocketColor,
          minExplosionDuration: minExplosionDuration,
          maxExplosionDuration: maxExplosionDuration,
          minParticleCount: minParticleCount,
          maxParticleCount: maxParticleCount,
          fadeOutDuration: fadeOutDuration,
        );

        // Wait for the game to process the addition of the rocket
        await game.ready();

        // Since adding components in Flame is asynchronous, we need to process the game update cycles
        // to ensure that the rocket is added before we make assertions.
        int iterations = 0;
        while (game.children.whereType<Rocket>().isEmpty && iterations < 10) {
          game.update(0.1);
          iterations++;
        }

        // Verify that a rocket has been added to the game
        final rockets = game.children.whereType<Rocket>().toList();
        expect(rockets.length, equals(1),
            reason: 'One rocket should be added to the game.');

        final rocket = rockets.first;

        // Verify the rocket's properties
        expect(rocket.colors, equals(colors));
        expect(rocket.rocketColor, equals(rocketColor));
        expect(rocket.minExplosionDuration, equals(minExplosionDuration));
        expect(rocket.maxExplosionDuration, equals(maxExplosionDuration));
        expect(rocket.minParticleCount, equals(minParticleCount));
        expect(rocket.maxParticleCount, equals(maxParticleCount));
        expect(rocket.fadeOutDuration, equals(fadeOutDuration));
      },
    );
  });
}
