// lib/main.dart
// ─────────────────────────────────────────────────────────────────────────────
// Akar Aplikasi MotoLog — Konfigurasi MultiProvider Global & Named Routes
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'core/services/auth_services.dart';
import 'core/state/app_state.dart'; // ◄── FIX: Impor AppState Terpusat

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
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  // Memanggil .initialize() berulang kali di setiap login adalah penyebab
  // deadlock thread native Google di HP fisik Android
  await GoogleSignIn.instance.initialize();
  await initializeDateFormatting('id_ID', null);

  runApp(const MotoLogApp());
}

class MotoLogApp extends StatelessWidget {
  const MotoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Provider Autentikasi (Sesi User)
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService.instance,
        ),
        // 2. FIX TUBES: Daftarkan AppState di akar agar terbaca di Dashboard & Riwayat Servis
        ChangeNotifierProvider<AppState>(create: (_) => AppState.instance),
      ],
      child: MaterialApp(
        title: 'MotoLog',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          if (settings.name == AppRoutes.addMotor) {
            final args = settings.arguments as Map<String, dynamic>?;
            final isOnboarding = args?['isOnboarding'] ?? false;

            return MaterialPageRoute(
              builder: (_) => AddMotorScreen(isOnboarding: isOnboarding),
              settings: settings,
            );
          }

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
          return null;
        },
      ),
    );
  }
}
