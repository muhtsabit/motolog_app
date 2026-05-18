// lib/core/utils/app_navigator.dart
//
// AppNavigator — navigasi terpusat yang selalu clear stack dengan benar.
//
// MASALAH SEBELUMNYA:
//   pushReplacementNamed hanya replace 1 screen teratas.
//   Jadi stack: Login → AddMotor → (replace) Dashboard
//   tapi saat back, masih ada Login di bawahnya → balik ke login.
//
// SOLUSI:
//   pushNamedAndRemoveUntil dengan predicate (route) => false
//   → hapus SEMUA screen lama, mulai fresh dari screen baru.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../state/app_state.dart';

abstract class AppNavigator {
  /// Setelah auth berhasil — cek motor lalu navigate dengan clear stack penuh.
  static void goAfterAuth(BuildContext context) {
    final destination = AppState.instance.hasMotor
        ? AppRoutes.dashboard
        : AppRoutes.addMotor;

    Navigator.pushNamedAndRemoveUntil(
      context,
      destination,
      (route) => false, // hapus SEMUA route lama
      arguments: destination == AppRoutes.addMotor
          ? {'isOnboarding': true}
          : null,
    );
  }

  /// Setelah tambah motor — selalu ke dashboard, clear stack penuh.
  static void goToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false, // hapus SEMUA route lama termasuk AddMotor
    );
  }

  /// Ke login — clear stack penuh (misalnya setelah logout).
  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
