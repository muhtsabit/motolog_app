// lib/features/motor/widgets/add_motor_hero_card.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/moto_logo.dart';

class AddMotorHeroCard extends StatelessWidget {
  final double contentWidth;
  const AddMotorHeroCard({super.key, required this.contentWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spaceXL,
        horizontal: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFCCEEF7),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Column(
        children: [
          const MotoLogo(
            size: 80,
            iconSize: 44,
            isCircle: false,
            bgOpacity: 1.0,
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Text(
            'Daftarkan motor Anda untuk mulai\ntracking perawatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
