import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'notification_service.dart';

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'photo_url': photoUrl};
  }

  UserModel copyWith({String? name, String? email, String? photoUrl}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class AuthResult<T> {
  final T? data;
  final String? error;
  bool get isSuccess => data != null;

  const AuthResult.success(this.data) : error = null;
  const AuthResult.cancelled() : data = null, error = null;
  const AuthResult.failure(this.error) : data = null;
}

class AuthService extends ChangeNotifier {
  AuthService._() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null) {
        _currentUser = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      }
    });
    tryInitLocalSession();
  }

  static final AuthService instance = AuthService._();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> tryInitLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user_session');
      if (userString != null) {
        _currentUser = UserModel.fromJson(json.decode(userString));
        notifyListeners();
        debugPrint("=== MOLOG: Sesi ditemukan, otomatis masuk dashboard ===");
      }
    } catch (e) {
      debugPrint("=== MOLOG: Gagal load sesi lokal ($e) ===");
    }
  }

  // Cek motor
  Future<bool> hasMotorcycles(String userId) async {
    try {
      debugPrint("=== MOLOG: Cek motor userId=$userId ===");
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/motorcycles/$userId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> list = json.decode(response.body);
        debugPrint("=== MOLOG: Jumlah motor = ${list.length} ===");
        return list.isNotEmpty;
      }
      return false;
    } catch (e) {
      debugPrint("=== MOLOG: Gagal cek motor ($e), fallback true ===");
      return true;
    }
  }

  // Login Manual
  Future<AuthResult<UserModel>> loginManual(
    String email,
    String password,
  ) async {
    try {
      debugPrint("=== MOLOG: Login manual $email ===");
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("=== MOLOG: Login HTTP ${response.statusCode} ===");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = UserModel.fromJson(data['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_session',
          json.encode(_currentUser!.toJson()),
        );
        if (data['token'] != null) {
          await prefs.setString('token', data['token'].toString());
        }

        unawaited(NotificationService.instance.syncToken(_currentUser!.id));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return AuthResult.success(_currentUser);
      } else {
        final data = json.decode(response.body);
        return AuthResult.failure(
          data['message'] ?? 'Email atau kata sandi salah.',
        );
      }
    } on TimeoutException {
      return const AuthResult.failure('Koneksi lambat. Periksa jaringan kamu.');
    } catch (e) {
      debugPrint("=== MOLOG: Error loginManual — $e ===");
      return const AuthResult.failure('Terjadi kesalahan. Coba lagi.');
    }
  }

  // Register
  Future<AuthResult<UserModel>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      debugPrint("=== MOLOG: Register $email ===");
      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name.trim(),
              'email': email.trim(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("=== MOLOG: Register HTTP ${response.statusCode} ===");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _currentUser = UserModel.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_session',
          json.encode(_currentUser!.toJson()),
        );
        if (data['token'] != null) {
          await prefs.setString('token', data['token'].toString());
        }

        unawaited(NotificationService.instance.syncToken(_currentUser!.id));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return AuthResult.success(_currentUser);
      } else {
        final data = json.decode(response.body);
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstMsg = (errors.values.first as List).first.toString();
          return AuthResult.failure(firstMsg);
        }
        return AuthResult.failure(
          data['message'] ?? 'Gagal mendaftar. Coba lagi.',
        );
      }
    } on TimeoutException {
      return const AuthResult.failure('Koneksi lambat. Periksa jaringan kamu.');
    } catch (e) {
      debugPrint("=== MOLOG: Error register — $e ===");
      return const AuthResult.failure('Terjadi kesalahan. Coba lagi.');
    }
  }

  // Google Sign-In
  Future<AuthResult<UserModel>> signInWithGoogle() async {
    try {
      debugPrint("=== MOLOG: Memulai Google Sign-In v7 ===");
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();

      if (googleUser == null) {
        debugPrint("=== MOLOG: Login dibatalkan pengguna ===");
        return const AuthResult.cancelled();
      }

      debugPrint("=== MOLOG: Akun terpilih = ${googleUser.email} ===");

      final String? idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        return const AuthResult.failure('Autentikasi gagal. Coba lagi.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      await _auth.signInWithCredential(credential);
      debugPrint("=== MOLOG: Firebase Auth berhasil ===");

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/login-google'),
            body: {'id_token': idToken},
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("=== MOLOG: HTTP ${response.statusCode} ===");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _currentUser = UserModel.fromJson(responseData['user']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'user_session',
          json.encode(_currentUser!.toJson()),
        );
        if (responseData['token'] != null) {
          await prefs.setString('token', responseData['token'].toString());
        }

        unawaited(NotificationService.instance.syncToken(_currentUser!.id));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
        return AuthResult.success(_currentUser);
      } else {
        return const AuthResult.failure(
          'Login gagal. Coba beberapa saat lagi.',
        );
      }
    } on TimeoutException {
      return const AuthResult.failure('Koneksi lambat. Periksa jaringan kamu.');
    } catch (e) {
      debugPrint("=== MOLOG: Error — $e ===");
      return const AuthResult.failure('Terjadi kesalahan. Coba lagi.');
    }
  }

  // Forgot Password
  Future<AuthResult<void>> forgotPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'Email tidak terdaftar.';
          break;
        case 'invalid-email':
          msg = 'Format email tidak valid.';
          break;
        default:
          msg = 'Gagal mengirim email. Coba lagi.';
      }
      return AuthResult.failure(msg);
    } catch (e) {
      return const AuthResult.failure('Koneksi bermasalah. Coba lagi.');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token') ?? '';

      await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/api/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $savedToken',
            },
          )
          .timeout(const Duration(seconds: 3));

      debugPrint("=== MOLOG: Sesi server Laravel berhasil dihapus ===");
    } catch (e) {
      debugPrint(
        "=== MOLOG: Server Laravel offline/RTO saat logout, lanjut bersihkan lokal ===",
      );
    }

    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_session');
      await prefs.remove('token');

      _currentUser = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      debugPrint("=== MOLOG: Logout lokal berhasil murni ===");
    } catch (e) {
      debugPrint("=== MOLOG: Error logout lokal — $e ===");
    }
  }
}
