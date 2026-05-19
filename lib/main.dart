// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';

// Screens
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password.dart';
import 'features/motor/add_motor_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/service/service_history_screen.dart';
import 'features/service/add_service_screen.dart';
import 'features/notification/notification_screen.dart';
import 'features/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ◄── 3. WAJIB INITIALIZE BAHASA INDONESIA SEBELUM RUNAPP
  await initializeDateFormatting('id_ID', null);

  runApp(const MotoLogApp());
}

class MotoLogApp extends StatelessWidget {
  const MotoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // darkTheme: AppTheme.dark, // aktifkan saat dark theme selesai
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,

      // Menggunakan onGenerateRoute agar bisa menangkap arguments 'isOnboarding' secara dinamis
      onGenerateRoute: (settings) {
        // 1. Handling khusus untuk halaman Add Motor yang butuh parameter data
        if (settings.name == AppRoutes.addMotor) {
          final args = settings.arguments as Map<String, dynamic>?;
          final isOnboarding = args?['isOnboarding'] ?? false;

          return MaterialPageRoute(
            builder: (_) => AddMotorScreen(isOnboarding: isOnboarding),
            settings: settings,
          );
        }

        // 2. Daftar rute standar aplikasi lainnya
        final routes = {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
          AppRoutes.dashboard: (_) => const DashboardScreen(),
          AppRoutes.serviceHistory: (_) => const ServiceHistoryScreen(),
          AppRoutes.addService: (_) => const AddServiceScreen(),
          AppRoutes.reminder: (_) => const NotificationScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }

        // Fallback jika route tidak ditemukan (opsional)
        return null;
      },
    );
  }
}
