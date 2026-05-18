// lib/core/state/app_state.dart
//
// AppState — Single source of truth untuk seluruh aplikasi.
// Menyimpan: currentUser, motors, isLoading.
//
// Arsitektur ini sengaja dibuat sederhana dengan ChangeNotifier
// supaya nanti mudah diganti Provider / Riverpod / Bloc + backend.
//
// Cara pakai di widget:
//   final state = AppState.instance;
//   state.addListener(() => setState(() {}));   // atau pakai ListenableBuilder
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../services/mock_db.dart'; // Pastikan path ini benar mengarah ke mock_db.dart yang diisi data
import '../../models/motor_model.dart';

// ── Simple user model ─────────────────────────────────────────────────────────
class AppUser {
  final String id;
  final String name;
  final String email;
  const AppUser({required this.id, required this.name, required this.email});
}

// ── AppState ──────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ── State ──────────────────────────────────────────────
  AppUser? _user;
  final List<MotorModel> _motors = [];

  // ── Getters ────────────────────────────────────────────
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  List<MotorModel> get motors => List.unmodifiable(_motors);
  bool get hasMotor => _motors.isNotEmpty;

  // Motor aktif yang sedang ditampilkan di dashboard
  MotorModel? get activeMotor => _motors.isNotEmpty ? _motors.first : null;

  // ── Auth actions ───────────────────────────────────────

  Future<String?> login(String email, String password) async {
    await _delay();

    // Mencari data user di MockDB berdasarkan email lowercase
    final record = MockDB.users[email.toLowerCase().trim()];
    if (record == null) return 'Email tidak terdaftar.';
    if (record['password'] != password) return 'Kata sandi salah.';

    _user = AppUser(
      id: record['id']!,
      name: record['name']!,
      email: email.toLowerCase().trim(),
    );

    // Muat motor milik user ini
    _loadMotors(_user!.id);
    notifyListeners();
    return null; // null = sukses
  }

  Future<String?> register(String name, String email, String password) async {
    await _delay();
    final key = email.toLowerCase().trim();
    if (MockDB.users.containsKey(key)) return 'Email sudah terdaftar.';

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    MockDB.users[key] = {'id': id, 'name': name, 'password': password};

    _user = AppUser(id: id, name: name, email: key);
    _motors.clear(); // user baru, belum ada motor
    notifyListeners();
    return null;
  }

  Future<String?> loginWithGoogle() async {
    await _delay(ms: 1000);
    const id = 'google_001';
    MockDB.users['google@gmail.com'] ??= {
      'id': id,
      'name': 'Pengguna Google',
      'password': '',
    };
    _user = const AppUser(
      id: id,
      name: 'Pengguna Google',
      email: 'google@gmail.com',
    );
    _loadMotors(id);
    notifyListeners();
    return null;
  }

  void logout() {
    _user = null;
    _motors.clear();
    notifyListeners();
  }

  // ── Motor actions ──────────────────────────────────────

  Future<String?> addMotor(MotorModel motor) async {
    await _delay();

    // Pastikan ada user yang aktif saat input motor dilakukan
    if (_user == null) {
      return 'Sesi berakhir. Silakan login kembali.';
    }

    // PAKSA: Ikat data motor ke userId milik user yang sedang login aktif saat ini
    final motorWithUser = motor.copyWith(userId: _user!.id);

    // Simpan data motor yang sudah terikat ke memory DB
    MockDB.motors.add(motorWithUser);
    _motors.add(motorWithUser);

    notifyListeners();
    return null; // Sukses
  }

  Future<void> updateMotorKm(String motorId, int newKm) async {
    await _delay(ms: 400);
    final idx = _motors.indexWhere((m) => m.id == motorId);
    if (idx == -1) return;
    final updated = _motors[idx].copyWith(currentKm: newKm);
    _motors[idx] = updated;

    final dbIdx = MockDB.motors.indexWhere((m) => m.id == motorId);
    if (dbIdx != -1) MockDB.motors[dbIdx] = updated;
    notifyListeners();
  }

  Future<void> deleteMotor(String motorId) async {
    await _delay();
    _motors.removeWhere((m) => m.id == motorId);
    MockDB.motors.removeWhere((m) => m.id == motorId);
    notifyListeners();
  }

  // ── Internal helpers ───────────────────────────────────

  void _loadMotors(String userId) {
    _motors
      ..clear()
      ..addAll(MockDB.motors.where((m) => m.userId == userId));
  }

  Future<void> _delay({int ms = 700}) =>
      Future.delayed(Duration(milliseconds: ms));
}
