// lib/features/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/moto_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 480 ? 400.0 : screenWidth - 48.0;
    final hPad = (screenWidth - contentWidth) / 2;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2BBCD4), Color(0xFF1A8CC4), Color(0xFF1272AE)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            // ── Scrollable Body ────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.paddingOf(context).top + 36,
                        ),

                        // ── Logo area ──────────────────────
                        _OnboardingLogo(contentWidth: contentWidth),

                        const SizedBox(height: AppConstants.spaceLG),

                        // ── Heading ────────────────────────
                        const _OnboardingHeading(),

                        const SizedBox(height: AppConstants.spaceLG),

                        // ── Feature cards ──────────────────
                        const _FeatureCard(
                          icon: Icons.speed_rounded,
                          title: 'Tracking Kilometer',
                          subtitle: 'Pantau jarak tempuh motor Anda',
                        ),
                        const SizedBox(height: AppConstants.spaceSM),
                        const _FeatureCard(
                          icon: Icons.notifications_rounded,
                          title: 'Reminder Otomatis',
                          subtitle: 'Notifikasi servis tepat waktu',
                        ),
                        const SizedBox(height: AppConstants.spaceSM),
                        const _FeatureCard(
                          icon: Icons.history_rounded,
                          title: 'Riwayat Lengkap',
                          subtitle: 'Catat semua perawatan motor',
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom Action Bar ──────────────────────────
            _OnboardingBottomBar(contentWidth: contentWidth, hPad: hPad),
          ],
        ),
      ),
    );
  }
}

class _OnboardingLogo extends StatelessWidget {
  final double contentWidth;
  const _OnboardingLogo({required this.contentWidth});

  static const double _boxSize = 120.0;
  static const double _notifSize = 32.0;
  static const double _smallLogoSize = 34.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: contentWidth,
      child: Center(
        child: SizedBox(
          width: _boxSize + _notifSize / 2,
          height: _boxSize + _smallLogoSize / 2 + 4,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Rounded square utama ─────────────────────
              Positioned(
                top: 0,
                left: 0,
                child: MotoLogo(size: _boxSize, iconSize: 56, isCircle: false),
              ),

              // ── Notif badge oranye (kanan atas) ──────────
              Positioned(
                top: -4,
                left: _boxSize - _notifSize / 2,
                child: Container(
                  width: _notifSize,
                  height: _notifSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B2C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40FF6B2C),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 17,
                  ),
                ),
              ),

              // ── Speed badge (pojok kiri bawah) ───────────
              Positioned(
                bottom: 12,
                left: -_smallLogoSize / 4,
                child: Container(
                  width: _smallLogoSize,
                  height: _smallLogoSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHeading extends StatelessWidget {
  const _OnboardingHeading();

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
          'Monitor kondisi motor, riwayat servis, dan reminder\n'
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

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMD,
        vertical: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: Colors.white.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B2C),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBottomBar extends StatelessWidget {
  final double contentWidth;
  final double hPad;

  const _OnboardingBottomBar({required this.contentWidth, required this.hPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        AppConstants.spaceMD,
        hPad,
        MediaQuery.paddingOf(context).bottom + AppConstants.spaceMD,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Masuk
          SizedBox(
            width: contentWidth,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Daftar
          SizedBox(
            width: contentWidth,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
