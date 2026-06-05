// lib/models/component_model.dart
// ─────────────────────────────────────────────────────────────────────────────
// ComponentModel — MotoLog (Proteksi Batas Ukur Batas Odometer & Progress Bar)
// ─────────────────────────────────────────────────────────────────────────────

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
  /// ◄── FIX: Jika hasil minus (telat servis), paksa mentok di angka 0 KM (Waktunya Ganti!) ──►
  int get remainingKm {
    final sisa = (lastServiceKm + intervalKm) - currentKm;
    return sisa < 0 ? 0 : sisa;
  }

  /// Rasio pemakaian 0.0 – 1.0 (untuk progress bar)
  /// ◄── FIX: Gunakan .clamp(0.0, 1.0) agar progress bar tidak overflow/error saat telat servis ──►
  double get progressRatio {
    if (intervalKm <= 0) return 0.0;
    final double rawRatio = usedKm / intervalKm;
    return rawRatio.clamp(0.0, 1.0);
  }
}
