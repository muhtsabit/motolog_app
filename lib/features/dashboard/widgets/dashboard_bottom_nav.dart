// lib/features/dashboard/widgets/dashboard_bottom_nav.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onTap;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    this.onTap,
  });

  void _handleNavigation(BuildContext context, int index) {
    // Jika tombol yg ditekan adalah halaman tempat user berada saat ini, abaikan
    if (index == selectedIndex) return;
    // Jika dari luar mengirimkan fungsi custom onTap, jalankan fungsi tersebut
    if (onTap != null) {
      onTap!(index);
      return;
    }

    // navigasi global otomatis aplikasi
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.serviceHistory);
        break;
      case 2:
        // Form input (cuma push biasa)
        Navigator.pushNamed(context, AppRoutes.addService);
        break;
      case 3:
        // halaman notifikasi
        Navigator.pushReplacementNamed(context, AppRoutes.reminder);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                selected: selectedIndex == 0,
                onTap: () => _handleNavigation(context, 0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                selected: selectedIndex == 1,
                onTap: () => _handleNavigation(context, 1),
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Tambah',
                selected: selectedIndex == 2,
                onTap: () => _handleNavigation(context, 2),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                selected: selectedIndex == 3,
                onTap: () => _handleNavigation(context, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textDisabled;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
