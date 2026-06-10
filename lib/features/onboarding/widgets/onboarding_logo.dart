import 'package:flutter/material.dart';
import '../../../shared/widgets/moto_logo.dart';

class OnboardingLogo extends StatelessWidget {
  final double contentWidth;
  const OnboardingLogo({super.key, required this.contentWidth});

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
