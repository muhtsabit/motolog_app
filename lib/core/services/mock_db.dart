// lib/core/services/mock_db.dart
//
// MockDB — satu tempat penyimpanan data in-memory untuk seluruh app.
// Semua service baca/tulis ke sini, bukan masing-masing punya List sendiri.
//
// Nanti saat backend sudah siap:
//   1. Hapus file ini
//   2. Ganti implementasi di AppState dengan API calls
//   3. Widget TIDAK perlu diubah sama sekali
// ─────────────────────────────────────────────────────────────────────────────

import '../../models/motor_model.dart';
import '../../models/service_model.dart';
import '../../models/notification_model.dart';

abstract class MockDB {
  // ── Users ─────────────────────────────────────────────
  // key = email lowercase
  // value = { id, name, password }
  // Ditambahkan akun default permanen untuk testing login lokal
  static final Map<String, Map<String, String>> users = {
    'test@gmail.com': {
      'id': 'user_default_01',
      'name': 'User Testing MotoLog',
      'password': 'password123',
    },
    'admin@gmail.com': {
      'id': 'user_default_02',
      'name': 'Admin MotoLog',
      'password': 'password123',
    },
  };

  // ── Motors ────────────────────────────────────────────
  static final List<MotorModel> motors = [];

  static final List<ServiceModel> serviceHistories = [];

  // ── Merek motor populer Indonesia ─────────────────────
  static const List<String> brands = [
    'Honda',
    'Yamaha',
    'Suzuki',
    'Kawasaki',
    'TVS',
    'Bajaj',
    'KTM',
    'Royal Enfield',
    'Vespa',
    'Lainnya',
  ];

  static final List<NotificationModel> notifications = [
    NotificationModel(
      id: 'notif_1',
      title: 'Oli Mesin Kritis!',
      message:
          'Oli mesin Anda telah melewati batas interval sejauh 120 KM. Segera ganti untuk menghindari kerusakan mesin.',
      type: NotificationType.critical,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationModel(
      id: 'notif_2',
      title: 'Busi Mendekati Batas',
      message:
          'Busi motor Anda tersisa 450 KM lagi sebelum waktu penggantian berikutnya.',
      type: NotificationType.warning,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationModel(
      id: 'notif_3',
      title: 'Tips MotoLog: Merawat Rantai',
      message:
          'Semprotkan cairan chain lube khusus setiap 500 KM atau setelah hujan agar rantai tidak kaku dan berkarat.',
      type: NotificationType.info,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];
}
