import 'package:fake_async/fake_async.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FireworksController Tests', () {
    test('Initialization', () {
      final controller = FireworksController();

      expect(controller.colors, isNotNull);
      expect(controller.colors.length, greaterThan(0));
      expect(controller.rocketColor, isNull);
      expect(controller.minExplosionDuration, 1.0);
      expect(controller.maxExplosionDuration, 3.0);
      expect(controller.minParticleCount, 100);
      expect(controller.maxParticleCount, 250);
      expect(controller.fadeOutDuration, 0.3);
      expect(controller.isDisposed, isFalse);
    });

    testWithGame<FireworksGame>(
      'Fire Single Rocket',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController(
          rocketColor: Colors.black,
          minExplosionDuration: 2.0,
          maxExplosionDuration: 2.0,
          minParticleCount: 50,
          maxParticleCount: 50,
          fadeOutDuration: 0.5,
        )..flameGame = game;

        controller.fireSingleRocket();

        // Process game updates to add the rocket
        await game.ready();
        game.update(0);

        // Wait for the rocket to be added
        int iterations = 0;
        while (game.children.whereType<Rocket>().isEmpty && iterations < 10) {
          game.update(0);
          iterations++;
        }

        final rockets = game.children.whereType<Rocket>().toList();
        expect(rockets.length, equals(1),
            reason: 'One rocket should be launched');

        final rocket = rockets.first;
        expect(rocket.colors.length, equals(1));
        expect(controller.colors, contains(rocket.colors.first));
        expect(rocket.rocketColor, equals(Colors.black));
        expect(rocket.minExplosionDuration, 2.0);
        expect(rocket.maxExplosionDuration, 2.0);
        expect(rocket.minParticleCount, 50);
        expect(rocket.maxParticleCount, 50);
        expect(rocket.fadeOutDuration, 0.5);
      },
    );

    testWithGame<FireworksGame>(
      'Fire Multiple Rockets',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController(
          minExplosionDuration: 1.5,
          maxExplosionDuration: 2.5,
          minParticleCount: 75,
          maxParticleCount: 125,
          fadeOutDuration: 0.4,
        )..flameGame = game;

        FakeAsync().run((async) {
          controller.fireMultipleRockets(
            minRockets: 5,
            maxRockets: 5,
            launchWindow: Duration(seconds: 1),
          );

          // Simulate time progression
          async.elapse(Duration(seconds: 1));

          // Process game updates
          game.update(0);

          final rockets = game.children.whereType<Rocket>().toList();
          expect(rockets.length, equals(5),
              reason: 'Five rockets should be launched');

          for (final rocket in rockets) {
            expect(rocket.colors, equals(controller.colors));
            expect(rocket.minExplosionDuration, 1.5);
            expect(rocket.maxExplosionDuration, 2.5);
            expect(rocket.minParticleCount, 75);
            expect(rocket.maxParticleCount, 125);
            expect(rocket.fadeOutDuration, 0.4);
          }
        });
      },
    );

    testWithGame<FireworksGame>(
      'Dispose Method',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController()..flameGame = game;

        controller.fireMultipleRockets(
          minRockets: 5,
          maxRockets: 5,
          launchWindow: Duration(seconds: 1),
        );

        controller.dispose();

        // Ensure that no rockets are launched after dispose
        await Future.delayed(Duration(seconds: 2));

        game.update(0);

        final rockets = game.children.whereType<Rocket>().toList();
        expect(rockets.length, equals(0),
            reason: 'No rockets should be launched after dispose');
        expect(controller.isDisposed, isTrue,
            reason: 'Controller should be marked as disposed');
      },
    );

    testWithGame<FireworksGame>(
      'Launch Rocket After Dispose',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController()..flameGame = game;

        controller.dispose();

        controller.launchRocket();

        game.update(0);

        final rockets = game.children.whereType<Rocket>().toList();
        expect(rockets.length, equals(0),
            reason: 'No rockets should be launched after dispose');
      },
    );

    testWithGame<FireworksGame>(
      'Fire Single Rocket with Custom Colors',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController(
          colors: [Colors.pink, Colors.cyan],
          rocketColor: Colors.grey,
        )..flameGame = game;

        controller.fireSingleRocket(
            color: Colors.orange, rocketColor: Colors.brown);

        // Process pending lifecycle events
        await game.ready();
        game.update(0);

        // Wait for the rocket to be added
        int iterations = 0;
        while (game.children.whereType<Rocket>().isEmpty && iterations < 10) {
          game.update(0);
          iterations++;
        }

        final rockets = game.children.whereType<Rocket>().toList();
        expect(rockets.length, equals(1));

        final rocket = rockets.first;
        expect(rocket.colors, equals([Colors.orange]));
        expect(rocket.rocketColor, equals(Colors.brown));
      },
    );

    testWithGame<FireworksGame>(
      'Fire Multiple Rockets with Custom Colors',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController(
          colors: [Colors.pink, Colors.cyan],
          rocketColor: Colors.grey,
        )..flameGame = game;

        FakeAsync().run((async) {
          controller.fireMultipleRockets(
            fireworksColors: [Colors.purple, Colors.yellow],
            minRockets: 3,
            maxRockets: 3,
            launchWindow: Duration(seconds: 1),
          );

          async.elapse(Duration(seconds: 1));
          game.update(0);

          final rockets = game.children.whereType<Rocket>().toList();
          expect(rockets.length, equals(3));

          for (final rocket in rockets) {
            expect(rocket.colors, equals([Colors.purple, Colors.yellow]));
            expect(rocket.rocketColor, equals(Colors.grey));
          }
        });
      },
    );

    testWithGame<FireworksGame>(
      'Ensure Timers are Cancelled on Dispose',
      () => FireworksGame(),
      (game) async {
        final controller = FireworksController()..flameGame = game;

        FakeAsync().run((async) {
          controller.fireMultipleRockets(
            minRockets: 10,
            maxRockets: 10,
            launchWindow: Duration(seconds: 5),
          );

          expect(controller.isDisposed, isFalse);

          // Dispose the controller before all rockets are launched
          async.elapse(Duration(seconds: 2));
          controller.dispose();

          // Simulate remaining time
          async.elapse(Duration(seconds: 3));

          game.update(0);

          final rockets = game.children.whereType<Rocket>().toList();
          // Since we disposed after 2 seconds, only some rockets should have been launched
          expect(rockets.length, lessThan(10));
          expect(controller.isDisposed, isTrue);

          // Ensure no further rockets are launched
          async.elapse(Duration(seconds: 5));
          game.update(0);

          final rocketsAfter = game.children.whereType<Rocket>().toList();
          expect(rocketsAfter.length, equals(rockets.length),
              reason: 'No additional rockets should be launched after dispose');
        });
      },
    );
  });
}
