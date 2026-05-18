// lib/core/utils/auth_redirect.dart
//
// Centralized post-auth navigation.
// Dipanggil setelah login / register / google sign-in berhasil.
// Cek apakah user punya motor → arahkan ke AddMotor atau Dashboard.
//
// Cara pakai:
//   await AuthRedirect.navigate(context, userId: user.id);
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../services/motor_services.dart';

class AuthRedirect {
  /// Cek motor lalu navigate — replace seluruh navigation stack.
  static Future<void> navigate(
    BuildContext context, {
    required String userId,
  }) async {
    final hasMotor = await MotorService.instance.hasMotor(userId);

    if (!context.mounted) return;

    if (hasMotor) {
      // User lama → langsung ke dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      // User baru → wajib tambah motor dulu (onboarding)
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.addMotor,
        arguments: {'isOnboarding': true},
      );
    }
  }
}
