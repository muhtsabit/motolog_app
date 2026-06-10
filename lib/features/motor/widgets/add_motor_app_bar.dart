import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class AddMotorAppBar extends StatelessWidget {
  final bool isOnboarding;
  const AddMotorAppBar({super.key, required this.isOnboarding});

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
