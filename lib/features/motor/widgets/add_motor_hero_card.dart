// lib/features/motor/widgets/add_motor_hero_card.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

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
        color: const Color(0xFFCCEEF7), // Teal muda sesuai Figma
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Column(
        children: [
          // Lingkaran aksen untuk membungkus ikon motor besar di bagian atas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.motorcycle,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Text(
            'Daftarkan motor Anda untuk mulai\ntracking perawatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
