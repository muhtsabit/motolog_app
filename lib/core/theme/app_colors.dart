// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// Semua warna MotoLog didefinisikan di sini.
/// Gunakan AppColors.* di seluruh aplikasi — jangan hardcode hex.
abstract class AppColors {
  // ── Brand / Seed ─────────────────────────────────────────────
  /// Seed color utama — teal biru sesuai Figma splash MotoLog
  static const Color seed = Color(0xFF1A8CC4);

  // ── Splash Gradient ──────────────────────────────────────────
  static const Color splashTop = Color(0xFF2BBCD4);
  static const Color splashMid = Color(0xFF1A8CC4);
  static const Color splashBottom = Color(0xFF1272AE);

  // ── Primary ──────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A8CC4);
  static const Color primaryLight = Color(0xFF2BBCD4);
  static const Color primaryDark = Color(0xFF1272AE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Secondary ────────────────────────────────────────────────
  static const Color secondary = Color(0xFFFF6B2C);
  static const Color secondaryLight = Color(0xFFFF8F5E);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // ── Surface / Background ─────────────────────────────────────
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF2F8);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFBCC5D4);

  // ── Status / Semantic ────────────────────────────────────────
  static const Color success = Color(0xFF12B76A);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Component Badge ──────────────────────────────────────────
  /// Status komponen motor
  static const Color statusOk = success;
  static const Color statusOkBg = successLight;
  static const Color statusWarn = warning;
  static const Color statusWarnBg = warningLight;
  static const Color statusCritical = danger;
  static const Color statusCriticalBg = dangerLight;

  // ── Border / Divider ─────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ── Shadow ───────────────────────────────────────────────────
  static const Color shadow = Color(0x1A000000);
  static const Color shadowMedium = Color(0x29000000);
}
