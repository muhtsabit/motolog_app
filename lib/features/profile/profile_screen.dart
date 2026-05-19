// lib/features/profile/profile_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: AppState.instance,
        builder: (context, _) {
          final state = AppState.instance;

          final userName = state.user?.name ?? 'Pengguna Demo';
          final userEmail = state.user?.email ?? 'demo@motolog.com';
          final totalMotors = state.motors.length;
          final totalServices = state.activeMotorServices.length;

          return Column(
            children: [
              // AppBar Hero Section (Info user sudah digeser lebih naik)
              ProfileAppBar(userName: userName, userEmail: userEmail),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Counter Cards (Anti-Overflow)
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
          );
        },
      ),
    );
  }
}
