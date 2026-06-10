import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';

import 'widgets/onboarding_logo.dart';
import 'widgets/onboarding_heading.dart';
import 'widgets/feature_card.dart';
import 'widgets/onboarding_bottom_bar.dart';

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

                        OnboardingLogo(contentWidth: contentWidth),
                        const SizedBox(height: AppConstants.spaceLG),
                        const OnboardingHeading(),
                        const SizedBox(height: AppConstants.spaceLG),

                        const FeatureCard(
                          icon: Icons.speed_rounded,
                          title: 'Tracking Kilometer',
                          subtitle: 'Pantau jarak tempuh motor Anda',
                        ),
                        const SizedBox(height: AppConstants.spaceSM),
                        const FeatureCard(
                          icon: Icons.notifications_rounded,
                          title: 'Reminder Otomatis',
                          subtitle: 'Notifikasi servis tepat waktu',
                        ),
                        const SizedBox(height: AppConstants.spaceSM),
                        const FeatureCard(
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

            OnboardingBottomBar(contentWidth: contentWidth, hPad: hPad),
          ],
        ),
      ),
    );
  }
}
