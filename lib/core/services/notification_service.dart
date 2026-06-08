// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';

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

  // Inisialisasi Utama Layanan Notifikasi MotoLog
  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // KEMBALI KE ASLI: Menggunakan positional argument tanpa kata 'settings'
    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final androidPlugin = _localNotif
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // REFAKTORING: Hanya membuat SATU channel tunggal, menggunakan positional arguments asli SDK lu
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'motolog_channel', // id
        'MotoLog Notifications', // name
        description: 'Notifikasi perawatan motor dari MotoLog', // description
        importance: Importance.high, // importance
      ),
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('=== FCM FG: ${message.notification?.title} ===');
      final notif = message.notification;
      if (notif != null) {
        // KEMBALI KE ASLI: Menggunakan positional arguments agar tidak memicu eror compile
        _localNotif.show(
          notif.hashCode, // id
          notif.title, // title
          notif.body, // body
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'motolog_channel', // channelId
              'MotoLog Notifications', // channelName
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  // Fungsi sinkronisasi token yang dipanggil reaktif oleh AuthService setelah login/register
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

  // Fungsi pembawa token ke REST API Laravel
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
