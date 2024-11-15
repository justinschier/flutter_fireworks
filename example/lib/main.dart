import 'package:example/starry_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fireworks/flutter_fireworks.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Fireworks',
      home: FireworksDemo(),
    );
  }
}

class FireworksDemo extends StatefulWidget {
  const FireworksDemo({super.key});

  @override
  State<FireworksDemo> createState() => _FireworksDemoState();
}

class _FireworksDemoState extends State<FireworksDemo> {
  final fireworksController = FireworksController(
    // Define a list of colors for the fireworks explosions
    // They will be picked randomly from this list for each explosion
    colors: [
      Color(0xFFFF4C40), // Coral
      Color(0xFF6347A6), // Purple Haze
      Color(0xFF7FB13B), // Greenery
      Color(0xFF82A0D1), // Serenity Blue
      Color(0xFFF7B3B2), // Rose Quartz
      Color(0xFF864542), // Marsala
      Color(0xFFB04A98), // Orchid
      Color(0xFF008F6C), // Sea Green
      Color(0xFFFFD033), // Pastel Yellow
      Color(0xFFFF6F7C), // Pink Grapefruit
    ],
    // The fastest explosion in seconds
    minExplosionDuration: 0.5,
    // The slowest explosion in seconds
    maxExplosionDuration: 3.5,
    // The minimum number of particles in an explosion
    minParticleCount: 125,
    // The maximum number of particles in an explosion
    maxParticleCount: 275,
    // The duration for particles to fade out in seconds
    fadeOutDuration: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          StarryBackground(),
          FireworksDisplay(
            controller: fireworksController,
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () => fireworksController.fireMultipleRockets(
            // Fire a random number of rockets between 5 and 20
            minRockets: 5,
            maxRockets: 20,
            // Fire all the rockets within this launch window
            launchWindow: Duration(milliseconds: 600),
          ),
          tooltip: 'Fire Multiple Rockets',
          shape: const CircleBorder(),
          backgroundColor: Colors.white.withOpacity(0.6),
          foregroundColor: Colors.black,
          child: const Icon(Icons.keyboard_double_arrow_up, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 44,
        color: Colors.white.withOpacity(0.05),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.pinkAccent,
                size: 30,
              ),
              tooltip: 'Fire Pink Rocket',
              onPressed: () => fireworksController.fireSingleRocket(
                color: Colors.pinkAccent,
                rocketColor: Colors.pink.shade100,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.blueAccent,
                size: 30,
              ),
              tooltip: 'Fire Blue Rocket',
              onPressed: () => fireworksController.fireSingleRocket(
                color: Colors.blueAccent,
                rocketColor: Colors.blue.shade100,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.greenAccent,
                size: 30,
              ),
              tooltip: 'Fire Green Rocket',
              onPressed: () => fireworksController.fireSingleRocket(
                color: Colors.greenAccent,
                rocketColor: Colors.green.shade100,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_up,
                color: Colors.amberAccent,
                size: 30,
              ),
              tooltip: 'Fire Amber Rocket',
              onPressed: () => fireworksController.fireSingleRocket(
                color: Colors.amberAccent,
                rocketColor: Colors.amber.shade100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
