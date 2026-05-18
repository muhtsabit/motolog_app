import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';

class DashboardAppBar extends StatelessWidget {
  final String motorName;
  final double hPad;

  const DashboardAppBar({
    super.key,
    required this.motorName,
    required this.hPad,
  });

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
        hPad,
        MediaQuery.paddingOf(context).top + AppConstants.spaceSM,
        hPad,
        AppConstants.spaceMD,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Motor Saya',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.80),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  motorName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _AppBarIconButton(icon: Icons.notifications_outlined, onTap: () {}),
          const SizedBox(width: AppConstants.spaceXS),
          _AppBarIconButton(
            icon: Icons.person_outline_rounded,
            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.20),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
