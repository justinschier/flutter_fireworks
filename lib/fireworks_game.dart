import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';

class FireworksGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  void launchRocket({
    required List<Color> colors,
    required Color? rocketColor,
    required double minExplosionDuration,
    required double maxExplosionDuration,
    required int minParticleCount,
    required int maxParticleCount,
    required double fadeOutDuration,
  }) {
    final rocket = Rocket(
      colors: colors,
      rocketColor: rocketColor,
      minExplosionDuration: minExplosionDuration,
      maxExplosionDuration: maxExplosionDuration,
      minParticleCount: minParticleCount,
      maxParticleCount: maxParticleCount,
      fadeOutDuration: fadeOutDuration,
    );
    add(rocket);
  }
}
