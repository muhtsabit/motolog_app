import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/moto_logo.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double contentWidth;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.contentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPad = (screenWidth - contentWidth) / 2;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2BBCD4), Color(0xFF1A8CC4), Color(0xFF1272AE)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        hPad,
        MediaQuery.paddingOf(context).top + AppConstants.spaceLG,
        hPad,
        AppConstants.spaceXL,
      ),
      child: Column(
        children: [
          // Logo
          const MotoLogo(size: 72, iconSize: 40, isCircle: false),

          const SizedBox(height: AppConstants.spaceMD),

          // Judul
          Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 6),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
