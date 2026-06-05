// lib/core/state/app_state.dart
// ─────────────────────────────────────────────────────────────────────────────
// AppState — Single Source of Truth MotoLog (Versi Riil REST API Laravel MySQL)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../../models/motor_model.dart';
import '../../models/service_model.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ── State Riil ──────────────────────────────────────────
  final List<MotorModel> _motors = [];
  List<ServiceModel> _serviceHistories = [];
  bool _isLoading = false;

  // ── Getters ────────────────────────────────────────────
  bool get isLoading => _isLoading;
  List<MotorModel> get motors => List.unmodifiable(_motors);
  List<ServiceModel> get serviceHistories =>
      List.unmodifiable(_serviceHistories);
  bool get hasMotor => _motors.isNotEmpty;

  // Ambil motor pertama sebagai motor aktif utama di dashboard
  MotorModel? get activeMotor => _motors.isNotEmpty ? _motors.first : null;

  // ── Aksi Motor (REST API) ───────────────────────────────

  Future<void> fetchActiveMotor(String userId) async {
    try {
      _isLoading = true;
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/motorcycles/$userId"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("=== MOLOG DEBUG: Response Motor Raw -> ${response.body}");
        final dynamic decodedData = json.decode(response.body);

        // Toleransi: Tangani jika Laravel me-return data dibungkus dalam objek 'data' atau list langsung
        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        }

        _motors.clear();
        if (rawList.isNotEmpty) {
          _motors.add(MotorModel.fromMap(rawList.first));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("=== MOLOG ERROR API: Gagal memuat data motor ($e) ===");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMotorKm(String motorId, int newKm) async {
    try {
      final response = await http
          .post(
            Uri.parse("${AppConfig.baseUrl}/api/motorcycles/$motorId/km"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"_method": "PATCH", "current_km": newKm}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 && activeMotor != null) {
        final updatedMotor = activeMotor!.copyWith(currentKm: newKm);
        _motors[0] = updatedMotor;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("=== MOLOG ERROR API: Gagal update kilometer ($e) ===");
    }
  }

  // ── Aksi Servis (REST API) ──────────────────────────────

  Future<String?> addService({
    required String motorcycleId,
    required int serviceKm,
    required String componentName,
    required String notes,
    required String serviceDate,
  }) async {
    try {
      // FIXING PAYLOAD: Kirim component_name sebagai string tunggal dan components array sebagai cadangan
      // agar cocok dengan segala bentuk validasi request validator di Laravel Controller kamu
      final Map<String, dynamic> payload = {
        "motorcycle_id": motorcycleId,
        "motor_id": motorcycleId,
        "service_km": serviceKm,
        "notes": notes,
        "service_date": serviceDate,
        "component_name": componentName,
        "components": [componentName],
      };

      final response = await http
          .post(
            Uri.parse("${AppConfig.baseUrl}/api/services"),
            headers: {"Content-Type": "application/json"},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 5));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Eksekusi pembaruan odometer & bunderan dashboard lokal secara reaktif seketika
        if (activeMotor != null && activeMotor!.id == motorcycleId) {
          final updatedMap = Map<String, int>.from(
            activeMotor!.componentLastServices,
          );
          updatedMap[componentName] = serviceKm;

          final updatedMotor = activeMotor!.copyWith(
            currentKm: serviceKm,
            componentLastServices: updatedMap,
          );

          _motors[0] = updatedMotor;
        }

        // Pancing penarikan riwayat terbaru langsung dari database backend
        await fetchServiceHistories(motorcycleId);
        return null;
      } else {
        return responseData['message'] ?? 'Gagal menyimpan catatan servis.';
      }
    } catch (e) {
      return 'Terjadi kesalahan koneksi ke server database laptop.';
    }
  }

  Future<void> fetchServiceHistories(String motorcycleId) async {
    try {
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/services/$motorcycleId"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("=== MOLOG DEBUG: Response Servis Raw -> ${response.body}");
        final dynamic decodedData = json.decode(response.body);

        // KUNCI AMAN PARSING: Izinkan pembacaan jika data berbentuk list langsung maupun dibungkus key 'data'
        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        } else if (decodedData is Map) {
          // Kasus jika Laravel mereturn object map collection
          rawList = decodedData.values.toList();
        }

        _serviceHistories = rawList
            .map((jsonItem) => ServiceModel.fromMap(jsonItem))
            .toList();

        _serviceHistories.sort(
          (a, b) => b.serviceDate.compareTo(a.serviceDate),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint("=== MOLOG ERROR API: Gagal memuat riwayat servis ($e) ===");
    }
  }
}
