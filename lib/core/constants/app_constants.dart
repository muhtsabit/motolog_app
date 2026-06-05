/// Konstanta global MotoLog — spacing, radius, animasi, dsb.
abstract class AppConstants {
  // ── Spacing ──────────────────────────────────────────────────
  static const double spaceXXS = 4.0;
  static const double spaceXS = 8.0;
  static const double spaceSM = 12.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ── Border Radius ────────────────────────────────────────────
  static const double radiusXS = 6.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 100.0;

  // ── Animation Duration ───────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // ── Page Padding ─────────────────────────────────────────────
  static const double pagePaddingH = 20.0; // horizontal
  static const double pagePaddingV = 24.0; // vertical

  // ── Icon Size ────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;

  // ── App Info ─────────────────────────────────────────────────
  static const String appName = 'MotoLog';
  static const String appVersion = '1.0.0';

  // ── Splash ───────────────────────────────────────────────────
  static const Duration splashDuration = Duration(seconds: 2);

  // Tambahkan baris ini di dalam class AppConstants kamu:
  static const List<String> motorBrands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'TVS',
    'Bajaj',
    'KTM',
    'Royal Enfield',
    'Vespa',
    'Lainnya',
  ];
}
