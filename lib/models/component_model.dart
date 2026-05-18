// lib/models/component_model.dart

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

  /// KM yang sudah terpakai sejak servis terakhir
  int get usedKm => currentKm - lastServiceKm;

  /// KM sisa sebelum harus servis lagi
  int get remainingKm => (lastServiceKm + intervalKm) - currentKm;

  /// Rasio pemakaian 0.0 – 1.0 (untuk progress bar)
  double get progressRatio => usedKm / intervalKm;
}
