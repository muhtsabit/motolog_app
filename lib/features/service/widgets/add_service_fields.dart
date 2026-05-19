// lib/features/service/widgets/add_service_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/service_model.dart';

class AddServiceFields extends StatelessWidget {
  final String? selectedComponent;
  final TextEditingController kmController;
  final TextEditingController dateController;
  final TextEditingController notesController;
  final ValueChanged<String?> onComponentChanged;
  final VoidCallback onTapDate;

  const AddServiceFields({
    super.key,
    required this.selectedComponent,
    required this.kmController,
    required this.dateController,
    required this.notesController,
    required this.onComponentChanged,
    required this.onTapDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Komponen/Part'),
        DropdownButtonFormField<String>(
          value: selectedComponent,
          hint: const Text('Pilih komponen', style: TextStyle(fontSize: 14)),
          items: kComponentOptions
              .map(
                (opt) => DropdownMenuItem(
                  value: opt.name,
                  child: Text(opt.name, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onComponentChanged,
          decoration: _decoration(),
          validator: (v) => v == null ? 'Pilih komponen dulu' : null,
        ),
        const SizedBox(height: AppConstants.spaceMD),

        _label('Kilometer Saat Ini'),
        TextFormField(
          controller: kmController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _ThousandFormatter(),
          ],
          decoration: _decoration(helper: 'Masukkan KM saat servis dilakukan'),
          validator: (v) => v!.isEmpty ? 'KM tidak boleh kosong' : null,
        ),
        const SizedBox(height: AppConstants.spaceMD),

        _label('Tanggal Servis'),
        TextFormField(
          controller: dateController,
          readOnly: true,
          onTap: onTapDate,
          decoration: _decoration(
            suffix: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
        ),
        const SizedBox(height: AppConstants.spaceMD),

        _label('Catatan (Opsional)'),
        TextFormField(
          controller: notesController,
          maxLines: 4,
          decoration: _decoration(hint: 'Tambahkan detail servis...'),
        ),
      ],
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
  );

  InputDecoration _decoration({String? hint, String? helper, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        helperText: helper,
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      );
}

class _ThousandFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    if (newV.text.isEmpty) return newV;
    final n = int.parse(newV.text.replaceAll('.', ''));
    final f = n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return newV.copyWith(
      text: f,
      selection: TextSelection.collapsed(offset: f.length),
    );
  }
}
