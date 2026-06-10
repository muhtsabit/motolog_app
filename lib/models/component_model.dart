import 'package:flutter/material.dart';

class ComponentModel {
  final String name;
  final IconData icon;
  final Color iconColor;
  final int lastServiceKm; // KM terakhir servis
  final int intervalKm; // interval servis (misal: 2000 km)
  final int currentKm; // KM motor saat ini

  const ComponentModel({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.lastServiceKm,
    required this.intervalKm,
    required this.currentKm,
  });

  int get usedKm => currentKm - lastServiceKm;
  int get remainingKm {
    final sisa = (lastServiceKm + intervalKm) - currentKm;
    return sisa < 0 ? 0 : sisa;
  }

  double get progressRatio {
    if (intervalKm <= 0) return 0.0;
    final double rawRatio = usedKm / intervalKm;
    return rawRatio.clamp(0.0, 1.0);
  }
}
