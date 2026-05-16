// lib/shared/widgets/moto_logo.dart
//
// MotoLogo — reusable logo widget pakai Icons.directions_bike_rounded.
// Dipakai di SplashScreen dan OnboardingScreen.
//
// Contoh:
//   MotoLogo(size: 120, iconSize: 64)   // Splash — rounded square besar
//   MotoLogo(size: 36, iconSize: 20)    // Onboarding — lingkaran kecil bawah
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class MotoLogo extends StatelessWidget {
  /// Ukuran container (lebar & tinggi)
  final double size;

  /// Ukuran icon di dalamnya
  final double iconSize;

  /// Pakai shape lingkaran (true) atau rounded square (false)
  final bool isCircle;

  /// Opacity background container
  final double bgOpacity;

  const MotoLogo({
    super.key,
    required this.size,
    required this.iconSize,
    this.isCircle = false,
    this.bgOpacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(bgOpacity),
        borderRadius: isCircle
            ? BorderRadius.circular(size / 2) // lingkaran penuh
            : BorderRadius.circular(size * 0.23), // rounded square
      ),
      child: Center(
        child: Icon(
          Icons.directions_bike_rounded,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
