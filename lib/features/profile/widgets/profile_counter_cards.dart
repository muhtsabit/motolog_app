// lib/features/profile/widgets/profile_counter_cards.dart
// ─────────────────────────────────────────────────────────────────────────────
// ProfileCounterCards — Komponen Kartu Statistik Dinamis & Interaktif
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ProfileCounterCards extends StatelessWidget {
  final int totalMotors;
  final int totalServices;
  final VoidCallback onMotorsTap; // Callback interaktivitas lembaran bawah

  const ProfileCounterCards({
    super.key,
    required this.totalMotors,
    required this.totalServices,
    required this.onMotorsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onMotorsTap, // Memicu aksi klik pop-up Multi-Motor
            child: _ItemCard(
              count: totalMotors,
              label: 'Motor Terdaftar',
              icon: Icons.directions_bike_rounded,
              iconColor: const Color(0xFF2BBCD4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ItemCard(
            count: totalServices,
            label: 'Riwayat Servis',
            icon: Icons.history_rounded,
            iconColor: const Color(0xFFFF6B2C),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _ItemCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
