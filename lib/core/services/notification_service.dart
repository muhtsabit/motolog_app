// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import '../constants/app_routes.dart';

// Navigator key global — didaftarkan di MaterialApp
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('=== FCM BG: ${message.notification?.title} ===');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Init local notifications + tap handler saat foreground
    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // Tap notifikasi saat app foreground → buka halaman notifikasi
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.reminder,
          (route) => route.settings.name == AppRoutes.dashboard,
        );
      },
    );

    // Buat channel Android
    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'motolog_channel',
        'MotoLog Notifications',
        description: 'Notifikasi perawatan motor dari MotoLog',
        importance: Importance.high,
      ),
    );

    // Tap notifikasi saat app background (sudah terbuka di memory)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('=== FCM TAP BG: ${message.notification?.title} ===');
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.reminder,
        (route) => route.settings.name == AppRoutes.dashboard,
      );
    });

    // Tap notifikasi saat app terminated (mati total)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        '=== FCM TAP TERMINATED: ${initialMessage.notification?.title} ===',
      );
      Future.delayed(const Duration(milliseconds: 800), () {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.reminder,
          (route) => route.settings.name == AppRoutes.dashboard,
        );
      });
    }

    // Tampilkan notifikasi saat app foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('=== FCM FG: ${message.notification?.title} ===');
      final notif = message.notification;
      if (notif != null) {
        _localNotif.show(
          notif.hashCode,
          notif.title,
          notif.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'motolog_channel',
              'MotoLog Notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  Future<void> syncToken(String userId) async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('=== FCM: Permission = ${settings.authorizationStatus} ===');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('=== FCM: Izin ditolak ===');
        return;
      }

      final token = await _fcm.getToken();
      debugPrint('=== FCM: Token = $token ===');

      if (token == null) return;

      await _sendToBackend(userId, token);

      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('=== FCM: Token refresh ===');
        _sendToBackend(userId, newToken);
      });
    } catch (e) {
      debugPrint('=== FCM: Error syncToken — $e ===');
    }
  }

  Future<void> _sendToBackend(String userId, String token) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/user/fcm-token'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'user_id': userId, 'fcm_token': token}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('=== FCM: Sync status = ${response.statusCode} ===');
      debugPrint('=== FCM: Sync body   = ${response.body} ===');
    } catch (e) {
      debugPrint('=== FCM: Gagal kirim token — $e ===');
    }
  }
}
