import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../services/auth_services.dart';

class AuthRedirect {
  static Future<void> navigate(
    BuildContext context, {
    required String userId,
  }) async {
    final hasMotor = await AuthService.instance.hasMotorcycles(userId);

    if (!context.mounted) return;

    if (hasMotor) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.addMotor,
        (route) => false,
        arguments: {'isOnboarding': true},
      );
    }
  }
}
