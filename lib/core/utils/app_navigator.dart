import 'package:flutter/material.dart';
import '../constants/app_routes.dart';
import '../services/auth_services.dart';

abstract class AppNavigator {
  static Future<void> goAfterAuth(
    BuildContext context, {
    required String userId,
  }) async {
    final hasMotor = await AuthService.instance.hasMotorcycles(userId);

    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      hasMotor ? AppRoutes.dashboard : AppRoutes.addMotor,
      (route) => false,
      arguments: hasMotor ? null : {'isOnboarding': true},
    );
  }

  static void goToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (route) => false,
    );
  }

  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
