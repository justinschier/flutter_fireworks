import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';

/// {@template fireworks_display}
/// A [StatefulWidget] that displays a fireworks animation.
/// Just put it at as the top layer of your Stack and then call the
/// `fireworksController.fireSingleRocket()` or
/// `fireworksController.fireMultipleRockets()` method to start the fireworks.
/// {@endtemplate}
class FireworksDisplay extends StatefulWidget {
  /// {@macro fireworks_display}
  const FireworksDisplay({
    required this.controller,
    super.key,
  });

  /// The controller for the fireworks display.
  final FireworksController controller;

  @override
  FireworksDisplayState createState() => FireworksDisplayState();
}

class FireworksDisplayState extends State<FireworksDisplay> {
  late final FireworksGame _flameGame = FireworksGame();

  @override
  void initState() {
    super.initState();
    widget.controller.flameGame = _flameGame;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      key: const Key('fireworksDisplay_ignorePointer'),
      child: GameWidget(game: _flameGame),
    );
  }
}
