import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/services/auth_services.dart';
import '../dashboard/widgets/dashboard_bottom_nav.dart';
import '../motor/add_motor_screen.dart';
import '../service/service_history_screen.dart';

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
  final int _selectedNav = -1;
  void _showEditMotorDialog(
    BuildContext context,
    AppState appState,
    String userId,
    dynamic motor,
  ) {
    final textController = TextEditingController(text: motor.name);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text(
          'Edit Nama Motor',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Nama Motor',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.trim().isNotEmpty) {
                await appState.updateMotor(
                  motor.id.toString(),
                  textController.text.trim(),
                  motor.brand.toString(),
                  userId,
                );
                if (context.mounted) Navigator.pop(dialogCtx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showMotorSelectionSheet(
    BuildContext context,
    AppState appState,
    String userId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (builderContext) {
        final activeMotorId = appState.activeMotor?.id;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(builderContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Kelola & Pilih Motor Aktif',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: appState.motors.length,
                    itemBuilder: (ctx, index) {
                      final motor = appState.motors[index];
                      final isSelected = motor.id == activeMotorId;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        leading: Icon(
                          Icons.directions_bike_rounded,
                          color: isSelected
                              ? const Color(0xFF2BBCD4)
                              : AppColors.textDisabled,
                        ),
                        title: Text(
                          motor.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${motor.brand} • ${motor.currentKm} km',
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () {
                                Navigator.pop(builderContext);
                                _showEditMotorDialog(
                                  context,
                                  appState,
                                  userId,
                                  motor,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Hapus Motor?'),
                                    content: Text(
                                      'Seluruh data dan riwayat servis motor ${motor.name} akan terhapus.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await appState.deleteMotor(
                                    motor.id.toString(),
                                    userId,
                                  );
                                  if (context.mounted)
                                    Navigator.pop(builderContext);
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          appState.changeActiveMotor(motor.id);
                          Navigator.pop(builderContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${motor.name} sekarang menjadi motor utama! 🏍️',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(builderContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AddMotorScreen(isOnboarding: false),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                      label: const Text(
                        'Tambah Motor Baru',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    final authService = context.watch<AuthService>();
    final appState = context.watch<AppState>();

    final userId = authService.currentUser?.id ?? '';
    final userName = authService.currentUser?.name ?? 'Pengguna MotoLog';
    final userEmail = authService.currentUser?.email ?? 'loading@motolog.com';

    final totalMotors = appState.motors.length;
    final totalServices = appState.serviceHistories.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ProfileAppBar(userName: userName, userEmail: userEmail),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileCounterCards(
                    totalMotors: totalMotors,
                    totalServices: totalServices,
                    onMotorsTap: () =>
                        _showMotorSelectionSheet(context, appState, userId),
                    onServicesTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServiceHistoryScreen(),
                        ),
                      );
                    },
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
