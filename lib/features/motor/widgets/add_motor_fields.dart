// lib/features/motor/widgets/add_motor_fields.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/mock_db.dart';

class AddMotorFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController kmController;
  final String? selectedBrand;
  final ValueChanged<String?> onBrandChanged;
  final Map<String, int> componentLastServices;

  const AddMotorFields({
    super.key,
    required this.nameController,
    required this.kmController,
    required this.selectedBrand,
    required this.onBrandChanged,
    required this.componentLastServices,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormLabel(text: 'Nama Motor'),
        const SizedBox(height: AppConstants.spaceXS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.motorcycle_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: AppConstants.spaceSM),
            Expanded(
              child: TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: _inputDecoration(hint: 'contoh: Honda BeAT 2022'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nama motor tidak boleh kosong'
                    : v.trim().length < 3
                    ? 'Minimal 3 karakter'
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMD),

        const _FormLabel(text: 'Merek'),
        const SizedBox(height: AppConstants.spaceXS),
        DropdownButtonFormField<String>(
          value: selectedBrand,
          isExpanded: true,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          decoration: _inputDecoration(hint: 'Pilih merek'),
          items: MockDB.brands
              .map((b) => DropdownMenuItem(value: b, child: Text(b)))
              .toList(),
          onChanged: onBrandChanged,
          validator: (v) => v == null || v.isEmpty
              ? 'Pilih merek motor terlebih dahulu'
              : null,
        ),
        const SizedBox(height: AppConstants.spaceMD),

        const _FormLabel(text: 'Kilometer Saat Ini'),
        const SizedBox(height: AppConstants.spaceXS),
        TextFormField(
          controller: kmController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
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
            return (num == null || num < 0)
                ? 'Masukkan angka yang valid'
                : num > 999999
                ? 'Kilometer terlalu besar'
                : null;
          },
        ),
        const SizedBox(height: AppConstants.spaceLG),

        // ── KONDISI KOMPONEN ONBOARDING UI ──────────────────
        const Divider(color: AppColors.border),
        const SizedBox(height: AppConstants.spaceSM),
        const Text(
          'Kondisi Komponen Saat Ini (Opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Centang jika komponen di bawah ini pernah diganti sebelumnya oleh Anda agar sisa jarak tempuh akurat.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMD),

        ...componentLastServices.keys.where((key) => key != 'Lainnya').map((
          componentName,
        ) {
          return _ExpandableComponentInput(
            componentName: componentName,
            onKmChanged: (val) => componentLastServices[componentName] = val,
          );
        }),

        _ExpandableCustomComponentInput(
          onDataChanged: (customName, kmValue) {
            if (customName.isNotEmpty) {
              componentLastServices[customName] = kmValue;
            }
          },
        ),
      ],
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

class _ExpandableComponentInput extends StatefulWidget {
  final String componentName;
  final ValueChanged<int> onKmChanged;

  const _ExpandableComponentInput({
    required this.componentName,
    required this.onKmChanged,
  });

  @override
  State<_ExpandableComponentInput> createState() =>
      _ExpandableComponentInputState();
}

class _ExpandableComponentInputState extends State<_ExpandableComponentInput> {
  bool _isExpanded = false;
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : AppColors.border,
          width: _isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              widget.componentName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _isExpanded
                  ? 'Buka untuk isi riwayat'
                  : 'Kondisi bawaan/default pabrik',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            value: _isExpanded,
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                _isExpanded = val ?? false;
                if (!_isExpanded) {
                  _ctrl.clear();
                  widget.onKmChanged(0);
                }
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLG + 24,
                0,
                AppConstants.spaceMD,
                AppConstants.spaceMD,
              ),
              child: TextFormField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 13),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandSeparatorFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: 'Contoh: 12000',
                  labelText: 'KM Motor saat komponen terakhir diservis',
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  suffixText: 'km',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMD,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  ),
                ),
                onChanged: (v) {
                  final parsed =
                      int.tryParse(v.replaceAll('.', '').trim()) ?? 0;
                  widget.onKmChanged(parsed);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ExpandableCustomComponentInput extends StatefulWidget {
  final Function(String, int) onDataChanged;

  const _ExpandableCustomComponentInput({required this.onDataChanged});

  @override
  State<_ExpandableCustomComponentInput> createState() =>
      _ExpandableCustomComponentInputState();
}

class _ExpandableCustomComponentInputState
    extends State<_ExpandableCustomComponentInput> {
  bool _isExpanded = false;
  final _nameCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  void _dispatchChanges() {
    final name = _nameCtrl.text.trim();
    final km = int.tryParse(_kmCtrl.text.replaceAll('.', '').trim()) ?? 0;
    widget.onDataChanged(name, km);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: _isExpanded ? AppColors.primary : AppColors.border,
          width: _isExpanded ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            title: const Text(
              'Lainnya (Komponen Kustom)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              _isExpanded
                  ? 'Masukkan nama komponen pilihan Anda'
                  : 'Tidak ada komponen kustom tambahan',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            value: _isExpanded,
            activeColor: AppColors.primary,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              setState(() {
                _isExpanded = val ?? false;
                if (!_isExpanded) {
                  _nameCtrl.clear();
                  _kmCtrl.clear();
                  widget.onDataChanged('', 0);
                }
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLG + 24,
                0,
                AppConstants.spaceMD,
                AppConstants.spaceMD,
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Contoh: Aki / Vanbelt / Kampas Kopling',
                      labelText: 'Nama Komponen Tambahan',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceMD,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSM,
                        ),
                      ),
                    ),
                    onChanged: (_) => _dispatchChanges(),
                  ),
                  const SizedBox(
                    height: AppConstants.spaceMD,
                  ), // ◄── SEKARANG SUDAH FIX AppConstants
                  TextFormField(
                    controller: _kmCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandSeparatorFormatter(),
                    ],
                    decoration: InputDecoration(
                      hintText: 'Contoh: 15000',
                      labelText: 'KM Motor saat komponen ini terakhir servis',
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      suffixText: 'km',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceMD,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSM,
                        ),
                      ),
                    ),
                    onChanged: (_) => _dispatchChanges(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ThousandSeparatorFormatter extends TextInputFormatter {
  const _ThousandSeparatorFormatter();

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
