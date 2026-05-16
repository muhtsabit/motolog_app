// lib/core/services/auth_service.dart
//
// Mock Auth Service — MotoLog
// Simulasi login, register, Google sign-in, forgot password.
// Ganti implementasi ini dengan Firebase/Supabase/REST API nanti.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

// ── Model ────────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  UserModel copyWith({String? name, String? email, String? photoUrl}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

// ── Result wrapper ────────────────────────────────────────────────────────────

class AuthResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => error == null;

  const AuthResult.success(this.data) : error = null;
  const AuthResult.failure(this.error) : data = null;
}

// ── Mock database ─────────────────────────────────────────────────────────────

// Simulasi "database" pengguna terdaftar
final _mockUsers = <String, _MockUserRecord>{};

class _MockUserRecord {
  final UserModel user;
  final String password;
  _MockUserRecord({required this.user, required this.password});
}

// ── Auth Service ──────────────────────────────────────────────────────────────

class AuthService {
  // Singleton
  AuthService._();
  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Stream untuk listen perubahan auth state
  final _authStateController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get authStateStream => _authStateController.stream;

  // ── Login ──────────────────────────────────────────────────
  Future<AuthResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    final record = _mockUsers[email.toLowerCase()];

    if (record == null) {
      return const AuthResult.failure('Email tidak terdaftar.');
    }
    if (record.password != password) {
      return const AuthResult.failure('Kata sandi salah.');
    }

    _currentUser = record.user;
    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser);
  }

  // ── Register ───────────────────────────────────────────────
  Future<AuthResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _simulateDelay();

    final key = email.toLowerCase();

    if (_mockUsers.containsKey(key)) {
      return const AuthResult.failure('Email sudah terdaftar.');
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      email: email.toLowerCase(),
    );

    _mockUsers[key] = _MockUserRecord(user: newUser, password: password);

    _currentUser = newUser;
    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser);
  }

  // ── Google Sign-In (mock) ──────────────────────────────────
  Future<AuthResult<UserModel>> signInWithGoogle() async {
    await _simulateDelay(ms: 1200);

    // Mock: selalu berhasil dengan user dummy Google
    const mockGoogleUser = UserModel(
      id: 'google_mock_001',
      name: 'Pengguna Google',
      email: 'pengguna@gmail.com',
      photoUrl: null, // nanti isi dengan URL foto Google
    );

    _mockUsers[mockGoogleUser.email] = _MockUserRecord(
      user: mockGoogleUser,
      password: '', // Google user tidak punya password
    );

    _currentUser = mockGoogleUser;
    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser);
  }

  // ── Forgot Password ────────────────────────────────────────
  Future<AuthResult<void>> forgotPassword({required String email}) async {
    await _simulateDelay(ms: 1500);

    final key = email.toLowerCase();

    if (!_mockUsers.containsKey(key)) {
      return const AuthResult.failure('Email tidak terdaftar.');
    }

    // Mock: simulasi kirim email reset
    // TODO: ganti dengan Firebase sendPasswordResetEmail / Supabase resetPasswordForEmail
    return const AuthResult.success(null);
  }

  // ── Reset Password ─────────────────────────────────────────
  Future<AuthResult<void>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await _simulateDelay();

    final key = email.toLowerCase();
    final record = _mockUsers[key];

    if (record == null) {
      return const AuthResult.failure('Email tidak ditemukan.');
    }

    _mockUsers[key] = _MockUserRecord(user: record.user, password: newPassword);

    return const AuthResult.success(null);
  }

  // ── Logout ─────────────────────────────────────────────────
  Future<void> logout() async {
    await _simulateDelay(ms: 300);
    _currentUser = null;
    _authStateController.add(null);
  }

  // ── Update Profile ─────────────────────────────────────────
  Future<AuthResult<UserModel>> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    await _simulateDelay();

    if (_currentUser == null) {
      return const AuthResult.failure('Tidak ada user yang login.');
    }

    _currentUser = _currentUser!.copyWith(name: name, photoUrl: photoUrl);
    _mockUsers[_currentUser!.email] = _MockUserRecord(
      user: _currentUser!,
      password: _mockUsers[_currentUser!.email]?.password ?? '',
    );

    _authStateController.add(_currentUser);
    return AuthResult.success(_currentUser);
  }

  // ── Helper ─────────────────────────────────────────────────
  Future<void> _simulateDelay({int ms = 800}) async {
    await Future.delayed(Duration(milliseconds: ms));
  }

  void dispose() {
    _authStateController.close();
  }
}
