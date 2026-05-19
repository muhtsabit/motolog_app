// lib/features/service/add_service_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../models/service_model.dart';
import 'widgets/add_service_app_bar.dart';
import 'widgets/add_service_fields.dart';
import 'widgets/add_service_save_bar.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // State Input
  String? _selectedComponent;
  final _kmCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Default tanggal hari ini
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    // Auto-fill KM berdasarkan odometer motor aktif saat ini agar user tidak repot ngetik dari nol
    final activeMotor = AppState.instance.activeMotor;
    if (activeMotor != null) {
      _kmCtrl.text = activeMotor.currentKm.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]}.',
      );
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final state = AppState.instance;

    // 1. Amankan pengecekan data jika null agar tidak silent-freeze atau crash
    if (state.activeMotor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Belum ada motor yang aktif pilih.'),
        ),
      );
      return;
    }

    if (_selectedComponent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih komponen terlebih dahulu.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Gunakan fallback ID jika session user kosong saat testing offline
      final currentUserId = state.user?.id ?? 'user_default_01';
      final currentMotorId = state.activeMotor!.id;

      // Buat objek model service baru
      final newService = ServiceModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        motorId: currentMotorId,
        userId: currentUserId,
        componentName: _selectedComponent!,
        serviceDate: _selectedDate,
        serviceKm: int.tryParse(_kmCtrl.text.replaceAll('.', '').trim()) ?? 0,
        notes: _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );

      // SIMPAN: Ini akan otomatis update Timeline Riwayat DAN Reset Progress Bar di Dashboard!
      await state.addService(newService);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Catatan servis berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );

      // Kembali ke halaman sebelumnya (Riwayat) dengan aman
      Navigator.pop(context);
    } catch (e) {
      // Jika ada error internal, matikan loading dan tunjukkan biang keroknya
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error input data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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
          const AddServiceAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                AppConstants.spaceMD,
                hPad,
                100,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Hero Card "Tambah Cepat" sesuai screenshot
                    const _AddServiceHero(),
                    const SizedBox(height: AppConstants.spaceLG),

                    // Input Fields
                    AddServiceFields(
                      selectedComponent: _selectedComponent,
                      kmController: _kmCtrl,
                      dateController: _dateCtrl,
                      notesController: _notesCtrl,
                      onComponentChanged: (val) =>
                          setState(() => _selectedComponent = val),
                      onTapDate: _pickDate,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AddServiceSaveBar(isLoading: _isLoading, onSave: _onSave, hPad: hPad),
        ],
      ),
    );
  }
}

class _AddServiceHero extends StatelessWidget {
  const _AddServiceHero();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2BBCD4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: const Color(0xFF2BBCD4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFF2BBCD4), size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Cepat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'Update catatan servis Anda',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
