// lib/features/profile/widgets/profile_menu_group.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.person_search_rounded,
            title: 'Edit Profil',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.border),
          _MenuTile(
            icon: Icons.notifications_none_rounded,
            title: 'Pengaturan Notifikasi',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.border),
          _MenuTile(
            icon: Icons.settings_outlined,
            title: 'Pengaturan Aplikasi',
            onTap: () {},
          ),
          const Divider(height: 1, color: AppColors.border),
          _MenuTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang MotoLog',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 18),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppColors.textDisabled,
        size: 12,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
    );
  }
}
