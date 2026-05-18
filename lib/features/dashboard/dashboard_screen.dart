// lib/features/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../models/component_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Mock data
  final String _motorName = 'Honda BeAT 2022';
  final int _currentKm = 15420;
  final bool _hasWarning = true;
  final String _warningText = 'Ganti oli masih dalam 580 KM lagi!';

  final List<ComponentModel> _components = [
    ComponentModel(
      name: 'Oli Mesin',
      icon: Icons.opacity_rounded,
      iconColor: Color(0xFFFF6B2C),
      lastServiceKm: 14000,
      intervalKm: 2000,
      currentKm: 15420,
    ),
    ComponentModel(
      name: 'Busi',
      icon: Icons.electric_bolt_rounded,
      iconColor: Color(0xFF3B82F6),
      lastServiceKm: 7000,
      intervalKm: 10000,
      currentKm: 15420,
    ),
    ComponentModel(
      name: 'Kampas Rem',
      icon: Icons.album_rounded,
      iconColor: Color(0xFF12B76A),
      lastServiceKm: 12000,
      intervalKm: 8000,
      currentKm: 15420,
    ),
    ComponentModel(
      name: 'Filter Udara',
      icon: Icons.air_rounded,
      iconColor: Color(0xFFFF6B2C),
      lastServiceKm: 10000,
      intervalKm: 6000,
      currentKm: 15420,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar gradient ──────────────────────────────
          _DashboardAppBar(
            motorName: _motorName,
            contentWidth: contentWidth,
            hPad: hPad,
          ),

          // ── Scrollable content ───────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spaceMD),

                  // KM Card
                  _KilometerCard(
                    currentKm: _currentKm,
                    onUpdate: _showUpdateKmDialog,
                  ),

                  // Warning banner
                  if (_hasWarning) ...[
                    const SizedBox(height: AppConstants.spaceMD),
                    _WarningBanner(text: _warningText),
                  ],

                  const SizedBox(height: AppConstants.spaceLG),

                  // Section title
                  const Text(
                    'Kondisi Komponen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceMD),

                  // Component list
                  ..._components.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spaceSM,
                      ),
                      child: _ComponentCard(component: c),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spaceLG),

                  // Action buttons
                  _DashboardActionButtons(
                    onAddService: () =>
                        Navigator.pushNamed(context, AppRoutes.addService),
                    onViewHistory: () =>
                        Navigator.pushNamed(context, AppRoutes.serviceHistory),
                  ),

                  SizedBox(
                    height:
                        MediaQuery.paddingOf(context).bottom +
                        AppConstants.spaceLG,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Nav ───────────────────────────────────
          _DashboardBottomNav(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        ],
      ),
    );
  }

  void _showUpdateKmDialog() {
    final ctrl = TextEditingController(text: _currentKm.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        title: const Text(
          'Update Kilometer',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'KM saat ini',
            suffixText: 'km',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: update km
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DashboardAppBar
// Gradient teal, "Motor Saya" label + nama motor bold, notif + profil icon
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardAppBar extends StatelessWidget {
  final String motorName;
  final double contentWidth;
  final double hPad;

  const _DashboardAppBar({
    required this.motorName,
    required this.contentWidth,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2BBCD4), Color(0xFF1272AE)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        hPad,
        MediaQuery.paddingOf(context).top + AppConstants.spaceSM,
        hPad,
        AppConstants.spaceMD,
      ),
      child: Row(
        children: [
          // Motor info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motor Saya',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.80),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  motorName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Notif icon
          _AppBarIconButton(icon: Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: AppConstants.spaceXS),
          // Profil icon
          _AppBarIconButton(
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _KilometerCard
// Card teal rounded, KM besar, tombol Update KM
// ─────────────────────────────────────────────────────────────────────────────
class _KilometerCard extends StatelessWidget {
  final int currentKm;
  final VoidCallback onUpdate;

  const _KilometerCard({required this.currentKm, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMD,
        vertical: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2BBCD4), Color(0xFF1A8CC4)],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Row(
        children: [
          // Speed icon
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

          // KM info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kilometer Saat Ini',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatKm(currentKm),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
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

          // Update button
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

  String _formatKm(int km) {
    return km.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _WarningBanner — oranye full-width, icon + teks
// ─────────────────────────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  final String text;
  const _WarningBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMD,
        vertical: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengingat Servis',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.90),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ComponentCard — card komponen motor dengan progress bar
// ─────────────────────────────────────────────────────────────────────────────
class _ComponentCard extends StatelessWidget {
  final ComponentModel component;
  const _ComponentCard({required this.component});

  @override
  Widget build(BuildContext context) {
    final progress = component.progressRatio.clamp(0.0, 1.0);
    final usedKm = component.usedKm;
    final totalKm = component.intervalKm;
    final remainingKm = component.remainingKm;
    final color = _progressColor(progress);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: component.iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  component.icon,
                  color: component.iconColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSM),

              // Name + sisa KM
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sisa ${_formatKm(remainingKm)} KM',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // KM counter kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatKm(usedKm),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '/ ${_formatKm(totalKm)} KM',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Color _progressColor(double ratio) {
    if (ratio >= 0.85) return AppColors.danger;
    if (ratio >= 0.65) return AppColors.warning;
    return AppColors.success;
  }

  String _formatKm(int km) {
    return km.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DashboardActionButtons — "Tambah Servis" + "Lihat Riwayat"
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardActionButtons extends StatelessWidget {
  final VoidCallback onAddService;
  final VoidCallback onViewHistory;

  const _DashboardActionButtons({
    required this.onAddService,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Tambah Servis
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAddService,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Tambah Servis',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSM),

        // Lihat Riwayat
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onViewHistory,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Lihat Riwayat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DashboardBottomNav — 4 tab: Beranda, Riwayat, Tambah, Notifikasi
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _DashboardBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
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
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.add_circle_rounded,
                label: 'Tambah',
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Notifikasi',
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
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
