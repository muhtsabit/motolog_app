import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../models/component_model.dart';

// Import sub-widgets yang sudah dipisah
import 'widgets/dashboard_app_bar.dart';
import 'widgets/kilometer_card.dart';
import 'widgets/warning_banner.dart';
import 'widgets/component_card.dart';
import 'widgets/dashboard_action_buttons.dart';
import 'widgets/dashboard_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

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

  // Generate data komponen secara dinamis berdasarkan KM motor saat ini DAN riwayat awal dari onboarding
  List<ComponentModel> _generateDynamicComponents(
    int currentKm,
    Map<String, int> lastServices,
  ) {
    return [
      ComponentModel(
        name: 'Oli Mesin',
        icon: Icons.opacity_rounded,
        iconColor: const Color(0xFFFF6B2C),
        // Ambil data dari onboarding, jika tidak diinput (null), otomatis default dihitung dari 0 KM
        lastServiceKm: lastServices['Oli Mesin'] ?? 0,
        intervalKm: 2000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Busi',
        icon: Icons.electric_bolt_rounded,
        iconColor: const Color(0xFF3B82F6),
        lastServiceKm: lastServices['Busi'] ?? 0,
        intervalKm: 10000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Kampas Rem',
        icon: Icons.album_rounded,
        iconColor: const Color(0xFF12B76A),
        lastServiceKm: lastServices['Kampas Rem'] ?? 0,
        intervalKm: 8000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Filter Udara',
        icon: Icons.air_rounded,
        iconColor: const Color(0xFFFF6B2C),
        lastServiceKm: lastServices['Filter Udara'] ?? 0,
        intervalKm: 6000,
        currentKm: currentKm,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    // Memantau perubahan single source of truth di AppState
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;

        // Ambil data motor aktif milik user yang sedang masuk
        final activeMotor = state.activeMotor;
        final motorName = activeMotor?.name ?? 'Tidak Ada Kendaraan';
        final currentKm = activeMotor?.currentKm ?? 0;

        // Hitung komponen & warning banner secara real-time
        // KODE BARU YANG BENAR:
        final lastServices = activeMotor?.componentLastServices ?? {};
        final components = _generateDynamicComponents(currentKm, lastServices);

        // Contoh kalkulasi alert: Ambil komponen oli (index 0)
        final oli = components.first;
        final bool hasWarning = currentKm > 0 && oli.remainingKm <= 1000;
        final String warningText =
            'Ganti oli motor Anda dalam ${oli.remainingKm} KM lagi!';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // AppBar gradient (Dinamis)
              DashboardAppBar(motorName: motorName, hPad: hPad),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.spaceMD),

                      // KM Card (Dinamis)
                      KilometerCard(
                        currentKm: currentKm,
                        onUpdate: () => _showUpdateKmDialog(currentKm),
                      ),

                      // Warning banner jika batas KM oli menipis
                      if (hasWarning) ...[
                        const SizedBox(height: AppConstants.spaceMD),
                        WarningBanner(text: warningText),
                      ],

                      const SizedBox(height: AppConstants.spaceLG),

                      const Text(
                        'Kondisi Komponen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceMD),

                      // List komponen dinamis mengikuti KM inputan terbaru
                      ...components.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppConstants.spaceSM,
                          ),
                          child: ComponentCard(component: c),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceLG),

                      // Navigasi tombol aksi
                      DashboardActionButtons(
                        onAddService: () =>
                            Navigator.pushNamed(context, AppRoutes.addService),
                        onViewHistory: () => Navigator.pushNamed(
                          context,
                          AppRoutes.serviceHistory,
                        ),
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

              // Bottom Nav
              DashboardBottomNav(
                selectedIndex: _selectedIndex,
                onTap: (i) => setState(() => _selectedIndex = i),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateKmDialog(int currentKm) {
    final ctrl = TextEditingController(text: currentKm.toString());
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
            onPressed: () async {
              final activeMotor = AppState.instance.activeMotor;
              final newKm = int.tryParse(ctrl.text) ?? currentKm;

              if (activeMotor != null) {
                // Perbarui KM motor di state & MockDB
                await AppState.instance.updateMotorKm(activeMotor.id, newKm);
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
