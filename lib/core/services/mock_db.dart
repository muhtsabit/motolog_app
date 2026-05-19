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
}
