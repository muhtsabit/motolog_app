// lib/features/dashboard/dashboard_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Dashboard Screen — MotoLog (Versi Integrasi Penuh REST API & Provider)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // ◄── KAIDAH PROVIDER UTAMA

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_services.dart';
import '../../core/state/app_state.dart'; // ◄── BACA DATA PUSAT DARI SINI
import '../../models/component_model.dart';

// Sub-widgets pendukung tetap aman terjaga konsistensinya
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
  final int _selectedIndex = 0;
  bool _isInit = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ◄── REAKTIF AMAN: Tarik data dari Laravel MySQL laptop pas halaman pertama kali dibuka ──►
    if (_isInit) {
      final currentUser = context.read<AuthService>().currentUser;
      if (currentUser != null) {
        context.read<AppState>().fetchActiveMotor(currentUser.id);
      }
      _isInit = false;
    }
  }

  // Fungsi pembantu pemicu refresh manual (Tarik dari atas layar)
  Future<void> _handleRefresh() async {
    final currentUser = context.read<AuthService>().currentUser;
    if (currentUser != null) {
      await context.read<AppState>().fetchActiveMotor(currentUser.id);
    }
  }

  // Generator matematika bunderan komponen menggunakan data REST API riil
  List<ComponentModel> _generateDynamicComponents(
    int currentKm,
    Map<String, int> lastServices,
  ) {
    return [
      ComponentModel(
        name: 'Oli Mesin',
        icon: Icons.opacity_rounded,
        iconColor: const Color(0xFFFF6B2C),
        lastServiceKm: lastServices['Oli Mesin'] ?? currentKm,
        intervalKm: 2000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Busi',
        icon: Icons.electric_bolt_rounded,
        iconColor: const Color(0xFF3B82F6),
        lastServiceKm: lastServices['Busi'] ?? currentKm,
        intervalKm: 10000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Kampas Rem',
        icon: Icons.album_rounded,
        iconColor: const Color(0xFF12B76A),
        lastServiceKm: lastServices['Kampas Rem'] ?? currentKm,
        intervalKm: 8000,
        currentKm: currentKm,
      ),
      ComponentModel(
        name: 'Filter Udara',
        icon: Icons.air_rounded,
        iconColor: const Color(0xFFFF6B2C),
        lastServiceKm: lastServices['Filter Udara'] ?? currentKm,
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

    // ◄── KUNCI UTAMA: Tonton perubahan state global AppState ecara realtime ──►
    final appState = context.watch<AppState>();
    final activeMotor = appState.activeMotor;

    // Ekstraksi Variabel dari database MySQL riil
    final motorName = activeMotor?.name ?? 'Tidak Ada Kendaraan';
    final currentKm = activeMotor?.currentKm ?? 0;
    final lastServices = activeMotor?.componentLastServices ?? {};

    final components = _generateDynamicComponents(currentKm, lastServices);

    // Hitung Banner Peringatan Oli
    final oli = components.first;
    final bool hasWarning = currentKm > 0 && oli.remainingKm <= 1000;
    final String warningText =
        'Ganti oli motor Anda dalam ${oli.remainingKm} KM lagi!';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: appState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _handleRefresh,
              child: Column(
                children: [
                  DashboardAppBar(motorName: motorName, hPad: hPad),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        AppConstants.spaceMD,
                        hPad,
                        MediaQuery.paddingOf(context).bottom +
                            AppConstants.spaceLG,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Odometer Card terikat fungsi dialog edit
                          KilometerCard(
                            currentKm: currentKm,
                            onUpdate: () => _showUpdateKmDialog(currentKm),
                          ),

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

                          // Render list progress bar komponen secara reaktif mutlak
                          ...components.map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppConstants.spaceSM,
                              ),
                              child: ComponentCard(component: c),
                            ),
                          ),

                          const SizedBox(height: AppConstants.spaceLG),
                          DashboardActionButtons(
                            onAddService: () async {
                              // Navigasi ke form input dengan membawa callback auto-refresh
                              final refresh = await Navigator.pushNamed(
                                context,
                                AppRoutes.addService,
                              );
                              if (refresh == true) _handleRefresh();
                            },
                            onViewHistory: () => Navigator.pushNamed(
                              context,
                              AppRoutes.serviceHistory,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DashboardBottomNav(selectedIndex: _selectedIndex),
                ],
              ),
            ),
    );
  }

  // ◄── UPDATE INTERFACE POP-UP DIALOG: Full UI Feedback & Loading State ──►
  void _showUpdateKmDialog(int currentKm) {
    final ctrl = TextEditingController(text: currentKm.toString());
    final dialogFormKey = GlobalKey<FormState>();

    // Variabel lokal dialog untuk mengontrol loading spinner di dalam pop-up
    bool isDialogLoading = false;

    showDialog(
      context: context,
      // Mencegah dialog ditutup paksa saat proses hit ke MySQL sedang berjalan
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
          title: const Text(
            'Update Kilometer',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Form(
            key: dialogFormKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: ctrl,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    enabled: !isDialogLoading, // Disable input saat loading
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'KM saat ini',
                      suffixText: 'km',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMD,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                      final parsed = int.tryParse(v.trim());
                      if (parsed == null) return 'Angka tidak valid';
                      if (parsed < currentKm) return 'Tidak boleh mundur';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDialogLoading
                    ? null
                    : () async {
                        if (!dialogFormKey.currentState!.validate()) return;
                        final inputKm = int.parse(ctrl.text.trim());

                        // 1. Nyalakan loading spinner di tombol
                        setDialogState(() => isDialogLoading = true);

                        // 2. Tembak fungsi update ke AppState Provider
                        try {
                          final currentActiveMotor = context
                              .read<AppState>()
                              .activeMotor;
                          if (currentActiveMotor != null) {
                            await context.read<AppState>().updateMotorKm(
                              currentActiveMotor.id,
                              inputKm,
                            );
                          }

                          // 3. Tutup dialog jika sukses
                          if (context.mounted) Navigator.pop(dialogContext);

                          // 4. RESPONS UI SUKSES: Munculkan Snackbar Hijau Melayang
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Kilometer Odometer Berhasil Diperbarui! 🚀',
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          // Matikan loading jika gagal
                          setDialogState(() => isDialogLoading = false);

                          // 5. RESPONS UI GAGAL: Munculkan Snackbar Merah
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal memperbarui database: $e'),
                                backgroundColor: AppColors.danger,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: isDialogLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
