import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingBottomBar extends StatelessWidget {
  final double contentWidth;
  final double hPad;

  const OnboardingBottomBar({
    super.key,
    required this.contentWidth,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        AppConstants.spaceMD,
        hPad,
        MediaQuery.paddingOf(context).bottom + AppConstants.spaceMD,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Masuk
          SizedBox(
            width: contentWidth,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: AppConstants.spaceSM),

          // Daftar
          SizedBox(
            width: contentWidth,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
              ),
              child: const Text(
                'Daftar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
