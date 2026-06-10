import 'package:flutter/material.dart';

class OnboardingHeading extends StatelessWidget {
  const OnboardingHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'MotoLog',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pantau Servis Motor\nLebih Mudah',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Monitor kondisi motor, riwayat servis, and reminder\n'
          'otomatis berdasarkan kilometer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.80),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
