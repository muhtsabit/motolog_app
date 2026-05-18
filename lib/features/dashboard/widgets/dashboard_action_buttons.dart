import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class DashboardActionButtons extends StatelessWidget {
  final VoidCallback onAddService;
  final VoidCallback onViewHistory;

  const DashboardActionButtons({
    super.key,
    required this.onAddService,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAddService,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'Tambah Servis',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spaceSM),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onViewHistory,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Lihat Riwayat',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
