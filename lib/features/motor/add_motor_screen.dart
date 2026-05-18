// lib/features/motor/add_motor_screen.dart
//
// Tambah Motor Screen — MotoLog
// Flow:
//   - Onboarding pertama kali → setelah auth jika belum punya motor (isOnboarding: true)
//   - Akses manual dari profil / bottom nav (isOnboarding: false)
//
// Layout sesuai Figma:
//   AppBar gradient + back button
//   Hero card teal muda + MotoLogo + subtitle
//   Form: Nama Motor, Merek (dropdown), Kilometer Saat Ini
//   Bottom bar: tombol Simpan Motor
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/motor_services.dart';
import '../../core/services/auth_services.dart';
import '../../models/motor_model.dart';
import '../../shared/widgets/moto_logo.dart';

class AddMotorScreen extends StatefulWidget {
  /// true  → flow onboarding, setelah simpan langsung ke Dashboard
  /// false → flow edit/tambah manual, setelah simpan pop back
  final bool isOnboarding;

  const AddMotorScreen({super.key, this.isOnboarding = false});

  @override
  State<AddMotorScreen> createState() => _AddMotorScreenState();
}

class _AddMotorScreenState extends State<AddMotorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();

  String? _selectedBrand;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = AuthService.instance.currentUser;
    final motor = MotorModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user?.id ?? 'guest',
      name: _nameCtrl.text.trim(),
      brand: _selectedBrand ?? '',
      currentKm: int.tryParse(_kmCtrl.text.replaceAll('.', '').trim()) ?? 0,
      createdAt: DateTime.now(),
    );

    await MotorService.instance.addMotor(motor);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (widget.isOnboarding) {
      // Onboarding: replace seluruh stack ke dashboard
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      // Manual: kembali ke layar sebelumnya
      Navigator.pop(context, motor);
    }
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
          // ── AppBar ──────────────────────────────────────
          _AddMotorAppBar(isOnboarding: widget.isOnboarding),

          // ── Scrollable form ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppConstants.spaceMD,
                hPad,
                // ruang untuk bottom bar
                100 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero card
                    _HeroCard(contentWidth: contentWidth),

                    const SizedBox(height: AppConstants.spaceLG),

                    // Nama Motor
                    _FormLabel(text: 'Nama Motor'),
                    const SizedBox(height: AppConstants.spaceXS),
                    _buildNameField(),

                    const SizedBox(height: AppConstants.spaceMD),

                    // Merek
                    _FormLabel(text: 'Merek'),
                    const SizedBox(height: AppConstants.spaceXS),
                    _buildBrandDropdown(),

                    const SizedBox(height: AppConstants.spaceMD),

                    // Kilometer
                    _FormLabel(text: 'Kilometer Saat Ini'),
                    const SizedBox(height: AppConstants.spaceXS),
                    _buildKmField(),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom bar: Simpan Motor ─────────────────────
          _SaveBar(
            contentWidth: contentWidth,
            hPad: hPad,
            isLoading: _isLoading,
            onSave: _onSave,
          ),
        ],
      ),
    );
  }

  // ── Field builders ───────────────────────────────────────

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameCtrl,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: _inputDecoration(hint: 'contoh: Honda BeAT 2022'),
      validator: (v) {
        if (v == null || v.trim().isEmpty)
          return 'Nama motor tidak boleh kosong';
        if (v.trim().length < 3) return 'Minimal 3 karakter';
        return null;
      },
    );
  }

  Widget _buildBrandDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBrand,
      isExpanded: true,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.textSecondary,
      ),
      decoration: _inputDecoration(hint: 'Pilih merek'),
      items: MotorService.brands
          .map((b) => DropdownMenuItem(value: b, child: Text(b)))
          .toList(),
      onChanged: (v) => setState(() => _selectedBrand = v),
      validator: (v) =>
          v == null || v.isEmpty ? 'Pilih merek motor terlebih dahulu' : null,
    );
  }

  Widget _buildKmField() {
    return TextFormField(
      controller: _kmCtrl,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _onSave(),
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _ThousandSeparatorFormatter(),
      ],
      decoration: _inputDecoration(
        hint: '15000',
        suffix: const Text(
          'km',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Kilometer tidak boleh kosong';
        final num = int.tryParse(v.replaceAll('.', ''));
        if (num == null || num < 0) return 'Masukkan angka yang valid';
        if (num > 999999) return 'Kilometer terlalu besar';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textDisabled),
      suffix: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMD,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AddMotorAppBar
// Gradient teal + back button (jika bukan onboarding pertama) + title
// ─────────────────────────────────────────────────────────────────────────────
class _AddMotorAppBar extends StatelessWidget {
  final bool isOnboarding;
  const _AddMotorAppBar({required this.isOnboarding});

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
        AppConstants.spaceSM,
        MediaQuery.paddingOf(context).top + AppConstants.spaceXS,
        AppConstants.spaceMD,
        AppConstants.spaceMD,
      ),
      child: Row(
        children: [
          // Back button — sembunyikan jika onboarding wajib
          if (!isOnboarding)
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: AppConstants.spaceMD),

          const Text(
            'Tambah Motor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _HeroCard
// Background teal muda, MotoLogo rounded square center + subtitle
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final double contentWidth;
  const _HeroCard({required this.contentWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.spaceXL,
        horizontal: AppConstants.spaceMD,
      ),
      decoration: BoxDecoration(
        // Teal muda — sesuai Figma
        color: const Color(0xFFCCEEF7),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Column(
        children: [
          // Logo rounded square — konsisten dengan screen lain
          const MotoLogo(
            size: 80,
            iconSize: 44,
            isCircle: false,
            bgOpacity: 1.0,
          ),
          const SizedBox(height: AppConstants.spaceMD),
          Text(
            'Daftarkan motor Anda untuk mulai\ntracking perawatan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary.withOpacity(0.85),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FormLabel — label field konsisten
// ─────────────────────────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SaveBar — bottom bar fixed dengan tombol Simpan Motor
// Lebar tombol = contentWidth (konsisten dengan seluruh app)
// ─────────────────────────────────────────────────────────────────────────────
class _SaveBar extends StatelessWidget {
  final double contentWidth;
  final double hPad;
  final bool isLoading;
  final VoidCallback onSave;

  const _SaveBar({
    required this.contentWidth,
    required this.hPad,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(
        hPad,
        AppConstants.spaceSM,
        hPad,
        MediaQuery.paddingOf(context).bottom + AppConstants.spaceMD,
      ),
      child: SizedBox(
        width: contentWidth,
        height: 52,
        child: ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Simpan Motor',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ThousandSeparatorFormatter
// Format input KM otomatis: 15000 → 15.000
// ─────────────────────────────────────────────────────────────────────────────
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('.', '');
    if (digits.isEmpty) return newValue.copyWith(text: '');

    final formatted = digits.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
