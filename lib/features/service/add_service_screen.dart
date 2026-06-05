// lib/features/service/add_service_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Add Service Screen — MotoLog
// Penyelarasan Form Input Dengan REST API Laravel MySQL Berdasarkan Kaidah Provider
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // ◄── WAJIB UNTUK AKSES REAKTIF PROVIDER
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';

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
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(_selectedDate);

    // ◄── KAIDAH PROVIDER: Ambil data awal odometer motor aktif secara aman via BuildContext ──►
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeMotor = context.read<AppState>().activeMotor;
      if (activeMotor != null) {
        setState(() {
          _kmCtrl.text = activeMotor.currentKm.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+$)'),
            (m) => '${m[1]}.',
          );
        });
      }
    });
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Ambil instance AppState menggunakan context read
    final appState = context.read<AppState>();

    if (appState.activeMotor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal: Belum ada motor yang aktif terpilih.'),
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

    // ◄── SINKRONISASI API: Pindahkan logika pembuatan model langsung ke parameter Provider ──►
    final int cleanKm =
        int.tryParse(_kmCtrl.text.replaceAll('.', '').trim()) ?? 0;
    final String currentMotorId = appState.activeMotor!.id;

    // Panggil fungsi addService terpusat yang sudah terkoneksi ke server Laravel MySQL laptop
    final errorResult = await appState.addService(
      motorcycleId: currentMotorId,
      serviceKm: cleanKm,
      componentName: _selectedComponent!,
      notes: _notesCtrl.text.trim(),
      serviceDate: DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDate), // Format baku MySQL
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Catatan servis berhasil disimpan ke MySQL laptop! 🛠️',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman sebelumnya (Halaman Riwayat otomatis ke-refresh)
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorResult), backgroundColor: Colors.red),
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
                    const _AddServiceHero(),
                    const SizedBox(height: AppConstants.spaceLG),
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
