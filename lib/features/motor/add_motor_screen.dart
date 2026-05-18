// lib/features/motor/add_motor_screen.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../core/utils/app_navigator.dart';
import '../../models/motor_model.dart';

// Import sub-widgets terpisah
import 'widgets/add_motor_app_bar.dart';
import 'widgets/add_motor_hero_card.dart';
import 'widgets/add_motor_fields.dart';
import 'widgets/add_motor_save_bar.dart';

class AddMotorScreen extends StatefulWidget {
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

  // State penampung data kilometer servis awal untuk komponen utama
  final Map<String, int> _componentLastServices = {
    'Oli Mesin': 0,
    'Busi': 0,
    'Kampas Rem': 0,
    'Filter Udara': 0,
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final currentUser = AppState.instance.user;

    if (currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis, silakan login kembali.')),
      );
      AppNavigator.goToLogin(context);
      return;
    }

    final int baseCurrentKm =
        int.tryParse(_kmCtrl.text.replaceAll('.', '').trim()) ?? 0;

    // Normalisasi: Jika user tidak mengisi/mencentang riwayat servis komponen,
    // maka kita samakan nilainya dengan currentKm motor saat ini (dianggap masih baru/aman).
    final Map<String, int> finalizedComponentServices = {};
    _componentLastServices.forEach((key, value) {
      finalizedComponentServices[key] = value > 0 ? value : baseCurrentKm;
    });

    final motor = MotorModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser.id,
      name: _nameCtrl.text.trim(),
      brand: _selectedBrand ?? '',
      currentKm: baseCurrentKm,
      createdAt: DateTime.now(),
      componentLastServices:
          finalizedComponentServices, // Data riwayat terikat sempurna ke model!
    );

    await AppState.instance.addMotor(motor);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (widget.isOnboarding) {
      AppNavigator.goToDashboard(context);
    } else {
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
          AddMotorAppBar(isOnboarding: widget.isOnboarding),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppConstants.spaceMD,
                hPad,
                120 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AddMotorHeroCard(contentWidth: contentWidth),
                    const SizedBox(height: AppConstants.spaceLG),

                    // Kumpulan input form utama dan form komponen kustom
                    AddMotorFields(
                      nameController: _nameCtrl,
                      kmController: _kmCtrl,
                      selectedBrand: _selectedBrand,
                      onBrandChanged: (v) => setState(() => _selectedBrand = v),
                      componentLastServices: _componentLastServices,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AddMotorSaveBar(
            contentWidth: contentWidth,
            hPad: hPad,
            isLoading: _isLoading,
            onSave: _onSave,
          ),
        ],
      ),
    );
  }
}
