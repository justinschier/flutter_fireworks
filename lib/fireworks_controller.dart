import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fireworks/lib.dart';

class FireworksController {
  FireworksController({
    List<Color>? colors,
    this.rocketColor,
    this.minExplosionDuration = 1.0,
    this.maxExplosionDuration = 3.0,
    this.minParticleCount = 100,
    this.maxParticleCount = 250,
    this.fadeOutDuration = 0.3,
  }) : colors = colors ??
            [
              Colors.pinkAccent,
              Colors.blueAccent,
              Colors.greenAccent,
              Colors.amberAccent,
            ];

  /// List of colors used for the fireworks explosions.
  final List<Color> colors;

  /// Color of the rocket trail (default is `QTColors.pinkMedium`).
  final Color? rocketColor;

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

  /// Reference to the Flame game instance.
  late final FireworksGame flameGame;

  /// Tracks whether the controller has been disposed.
  bool _disposed = false;

  /// Public read-only getter to check if the controller is disposed.
  @visibleForTesting
  bool get isDisposed => _disposed;

  // Add a list to keep track of timers
  final List<Timer> _timers = [];

  void fireSingleRocket({Color? color, Color? rocketColor}) {
    if (_disposed) return;

    flameGame.launchRocket(
      colors: [color ?? (colors..shuffle()).first],
      rocketColor: rocketColor ?? this.rocketColor,
      minExplosionDuration: minExplosionDuration,
      maxExplosionDuration: maxExplosionDuration,
      minParticleCount: minParticleCount,
      maxParticleCount: maxParticleCount,
      fadeOutDuration: fadeOutDuration,
    );
  }

  void fireMultipleRockets({
    List<Color>? fireworksColors,
    int minRockets = 6,
    int maxRockets = 14,
    Duration launchWindow = const Duration(seconds: 2),
  }) {
    if (_disposed) return;

    final rocketColors = fireworksColors ?? colors;
    final random = Random();
    final rocketsToFire =
        random.nextInt(maxRockets - minRockets + 1) + minRockets;
    final totalDuration = launchWindow.inMilliseconds / 1000.0;
    final interval = totalDuration / rocketsToFire;

    for (var i = 0; i < rocketsToFire; i++) {
      final delayMilliseconds = (interval * 1000 * i).toInt();

      final timer = Timer(Duration(milliseconds: delayMilliseconds), () {
        if (_disposed) return;
        flameGame.launchRocket(
          colors: rocketColors,
          rocketColor: rocketColor,
          minExplosionDuration: minExplosionDuration,
          maxExplosionDuration: maxExplosionDuration,
          minParticleCount: minParticleCount,
          maxParticleCount: maxParticleCount,
          fadeOutDuration: fadeOutDuration,
        );
      });
      _timers.add(timer);
    }
  }

  void launchRocket() {
    if (_disposed) return;
    flameGame.launchRocket(
      colors: colors,
      rocketColor: rocketColor,
      minExplosionDuration: minExplosionDuration,
      maxExplosionDuration: maxExplosionDuration,
      minParticleCount: minParticleCount,
      maxParticleCount: maxParticleCount,
      fadeOutDuration: fadeOutDuration,
    );
  }

  void dispose() {
    _disposed = true;

    for (final timer in _timers) {
      timer.cancel();
    }

    _timers.clear();
  }
}
