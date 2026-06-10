import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:motolog/core/services/auth_services.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../../core/constants/app_config.dart';
import '../../core/state/app_state.dart';

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

    final currentUser = AuthService.instance.currentUser;
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
    final Map<String, int> finalizedComponents = {};
    _componentLastServices.forEach((key, value) {
      finalizedComponents[key] = value > 0 ? value : baseCurrentKm;
    });

    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/motorcycles'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'user_id': currentUser.id,
              'name': _nameCtrl.text.trim(),
              'brand': _selectedBrand ?? '',
              'current_km': baseCurrentKm,
              'components': finalizedComponents,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await context.read<AppState>().fetchActiveMotor(currentUser.id);

        if (!mounted) return;
        setState(() => _isLoading = false);

        if (widget.isOnboarding) {
          AppNavigator.goToDashboard(context);
        } else {
          Navigator.pop(context, true);
        }
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final body = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['message'] ?? 'Gagal menyimpan motor.'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koneksi lambat. Periksa jaringan kamu.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Coba lagi.'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
