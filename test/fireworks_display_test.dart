import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FireworksDisplay Tests', () {
    late FireworksController controller;
    late Widget widget;

    setUp(() {
      controller = FireworksController();
      widget = MaterialApp(
        home: Scaffold(
          body: FireworksDisplay(controller: controller),
        ),
      );
    });

    testWidgets('Initialization and Controller Setup',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      // Allow the widget tree to build
      await tester.pump();

      // Verify that the controller's flameGame is set
      expect(controller.flameGame, isNotNull);
      expect(controller.flameGame, isA<FireworksGame>());

      // Verify that the widget builds a GameWidget
      expect(find.byWidgetPredicate((widget) => widget is GameWidget),
          findsOneWidget);

      // Verify we are ignoring pointer events
      final ignorePointerFinder =
          find.byKey(const Key('fireworksDisplay_ignorePointer'));
      expect(ignorePointerFinder, findsOneWidget);
    });

    testWidgets('Dispose Method is Called on Widget Dispose',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      // Verify that the controller is not disposed initially
      expect(controller.isDisposed, isFalse);

      // Remove the widget from the tree
      await tester.pumpWidget(Container());
      await tester.pump();

      // Verify that the controller is disposed
      expect(controller.isDisposed, isTrue);
    });

    testWidgets('Firing Rockets Updates the Game', (WidgetTester tester) async {
      final controller = FireworksController(
        minExplosionDuration: 1.0,
        maxExplosionDuration: 1.0,
        minParticleCount: 10,
        maxParticleCount: 10,
        fadeOutDuration: 0.5,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FireworksDisplay(controller: controller),
        ),
      ));

      final game = controller.flameGame;

      // Ensure the game is fully loaded
      await game.onLoad();

      // Fire a single rocket
      controller.fireSingleRocket();

      // Process game updates until the rocket is added
      int iterations = 0;
      while (game.children.whereType<Rocket>().isEmpty && iterations < 20) {
        game.update(0.1);
        iterations++;
        await tester.pump(Duration(milliseconds: 50));
      }

      // Verify that a rocket has been added to the game
      final rockets = game.children.whereType<Rocket>().toList();
      expect(rockets.length, equals(1),
          reason: 'One rocket should be in the game');

      // Use tester.runAsync to handle timers
      await tester.runAsync(() async {
        // Fire multiple rockets
        controller.fireMultipleRockets(
          minRockets: 3,
          maxRockets: 3,
          launchWindow: Duration(seconds: 1),
        );

        // Wait for the timers to execute
        await Future.delayed(Duration(seconds: 1));

        // Process game updates
        iterations = 0;
        while (
            game.children.whereType<Rocket>().length < 4 && iterations < 20) {
          game.update(0.1);
          iterations++;
          await tester.pump(Duration(milliseconds: 50));
        }

        // Verify that more rockets have been added
        final totalRockets = game.children.whereType<Rocket>().toList();
        expect(totalRockets.length, equals(4),
            reason: 'Total of 4 rockets should be in the game');
      });
    });

    testWidgets('GameWidget builds with correct game',
        (WidgetTester tester) async {
      await tester.pumpWidget(widget);

      await tester.pump(); // Remove pumpAndSettle

      // Find the GameWidget
      final gameWidgetFinder =
          find.byWidgetPredicate((widget) => widget is GameWidget);
      expect(gameWidgetFinder, findsOneWidget);

      // Verify that the GameWidget is built with the correct game
      final gameWidget = tester.widget(gameWidgetFinder) as GameWidget;
      expect(gameWidget.game, equals(controller.flameGame));
    });
  });
}
