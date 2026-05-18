// lib/features/motor/widgets/add_motor_save_bar.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class AddMotorSaveBar extends StatelessWidget {
  final double contentWidth;
  final double hPad;
  final bool isLoading;
  final VoidCallback onSave;

  const AddMotorSaveBar({
    super.key,
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
