import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class KilometerCard extends StatelessWidget {
  final int currentKm;
  final VoidCallback onUpdate;

  const KilometerCard({
    super.key,
    required this.currentKm,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2BBCD4), Color(0xFF1A8CC4)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.speed_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilometer Saat Ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                Text(
                  currentKm.toString().replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+$)'),
                    (m) => '${m[1]}.',
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'km',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onUpdate,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMD,
                vertical: AppConstants.spaceXS,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: const Text(
                'Update KM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
