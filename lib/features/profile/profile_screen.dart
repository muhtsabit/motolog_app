// lib/features/profile/profile_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Profile Screen — MotoLog
// Sinkronisasi Sesi Pengguna & Statistik Motor Berbasis Arsitektur Provider
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ◄── Diperlukan untuk kaidah context.watch
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/services/auth_services.dart'; // ◄── Diperlukan untuk membaca data user riil
import '../dashboard/widgets/dashboard_bottom_nav.dart';

import 'widgets/profile_app_bar.dart';
import 'widgets/profile_counter_cards.dart';
import 'widgets/profile_menu_group.dart';
import 'widgets/profile_logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    // ◄── KAIDAH PROVIDER: Daftarkan watch listener di tingkat atas build method ──►
    final authService = context.watch<AuthService>();
    final appState = context.watch<AppState>();

    // Ambil data user dari AuthService (Bukan dari AppState MockDB lagi)
    final userName = authService.currentUser?.name ?? 'Pengguna MotoLog';
    final userEmail = authService.currentUser?.email ?? 'loading@motolog.com';

    // Ambil data statistik dari AppState riil REST API
    final totalMotors = appState.motors.length;
    final totalServices = appState.serviceHistories.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // AppBar Hero Section menampilkan info user riil terotentikasi
          ProfileAppBar(userName: userName, userEmail: userEmail),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Counter Cards menampilkan total motor & total servis dari MySQL
                  ProfileCounterCards(
                    totalMotors: totalMotors,
                    totalServices: totalServices,
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'PENGATURAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDisabled,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Grouped Menu List
                  const ProfileMenuGroup(),
                  const Spacer(),
                  const ProfileLogoutButton(),
                ],
              ),
            ),
          ),

          DashboardBottomNav(selectedIndex: _selectedNav),
        ],
      ),
    );
  }
}
