import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class ProfileMenuGroup extends StatelessWidget {
  const ProfileMenuGroup({super.key});

  void _showAboutMotoLog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'MotoLog',
      applicationVersion: 'v1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFF2BBCD4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.directions_bike_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      applicationLegalese: '© 2026 MotoLog.\nAll rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'MotoLog adalah aplikasi pencatatan dan monitoring perawatan komponen sepeda motor berbasis kilometer reaktif.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Copyright © 2026 MotoLog.\nDeveloped by Muhamad Tsabit.\nPowered by Flutter and Laravel.\nAll registered trademarks belong to their respective owners.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

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
            onTap: () => _showAboutMotoLog(context),
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
