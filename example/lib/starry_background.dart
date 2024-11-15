import 'dart:math';

import 'package:flutter/material.dart';

class StarryBackground extends StatelessWidget {
  const StarryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        NightBackground(),
        Starfield(),
      ],
    );
  }
}

class NightBackground extends StatelessWidget {
  const NightBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topCenter,
          colors: [
            Color(0xFF20242F),
            Color(0xFF131517),
          ],
        ),
      ),
    );
  }
}

class Star {
  final Offset position;
  final double radius;

  Star(this.position, this.radius);
}

class Starfield extends StatefulWidget {
  const Starfield({super.key});

  @override
  StarfieldState createState() => StarfieldState();
}

class StarfieldState extends State<Starfield> {
  late List<Star> _stars;

  @override
  void initState() {
    super.initState();
    _generateStars();
  }

  void _generateStars() {
    final random = Random();
    final starCount = 200;
    _stars = List.generate(starCount, (index) {
      final x = random.nextDouble();
      final y = random.nextDouble() * (index < starCount * 0.75 ? 0.5 : 1.0);
      final radius = random.nextDouble() * 1.5;
      return Star(Offset(x, y), radius);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(_stars),
      size: Size.infinite,
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  final List<Star> stars;

  _StarfieldPainter(this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.8);
    for (final star in stars) {
      final x = star.position.dx * size.width;
      final y = star.position.dy * size.height;
      final radius = star.radius;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
