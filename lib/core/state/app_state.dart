import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/app_config.dart';
import '../../models/motor_model.dart';
import '../../models/service_model.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // State Riil Terpusat
  final List<MotorModel> _motors = [];
  List<ServiceModel> _serviceHistories = [];
  bool _isLoading = false;
  String? _selectedMotorId;

  // Getters
  bool get isLoading => _isLoading;
  List<MotorModel> get motors => List.unmodifiable(_motors);
  List<ServiceModel> get serviceHistories =>
      List.unmodifiable(_serviceHistories);
  bool get hasMotor => _motors.isNotEmpty;

  MotorModel? get activeMotor {
    if (_motors.isEmpty) return null;
    if (_selectedMotorId == null) return _motors.first;

    return _motors.firstWhere(
      (m) => m.id == _selectedMotorId,
      orElse: () => _motors.first,
    );
  }

  // Fungsi Pemindah Fokus Motor dari Profil
  void changeActiveMotor(String motorId) {
    _selectedMotorId = motorId;
    fetchServiceHistories(motorId);

    notifyListeners(); // Pemicu reaktif agar Dashboard ikut berubah total
  }

  Future<void> fetchActiveMotor(String userId) async {
    try {
      _isLoading = true;
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/motorcycles/$userId"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        debugPrint("=== MOLOG DEBUG: Response Motor Raw -> ${response.body}");
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        }

        _motors.clear();
        for (var item in rawList) {
          _motors.add(MotorModel.fromMap(item));
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
        // Update data motor lokal di dalam array list agar sinkron
        final index = _motors.indexWhere((m) => m.id == motorId);
        if (index != -1) {
          _motors[index] = _motors[index].copyWith(currentKm: newKm);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("=== MOLOG ERROR API: Gagal update kilometer ($e) ===");
    }
  }

  Future<String?> addService({
    required String motorcycleId,
    required int serviceKm,
    required String componentName,
    required String notes,
    required String serviceDate,
  }) async {
    try {
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
        // Sinkronisasi mutasi data komponen
        final index = _motors.indexWhere((m) => m.id == motorcycleId);
        if (index != -1) {
          final updatedMap = Map<String, int>.from(
            _motors[index].componentLastServices,
          );
          updatedMap[componentName] = serviceKm;

          _motors[index] = _motors[index].copyWith(
            currentKm: serviceKm,
            componentLastServices: updatedMap,
          );
        }

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

        List<dynamic> rawList = [];
        if (decodedData is List) {
          rawList = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          rawList = decodedData['data'];
        } else if (decodedData is Map) {
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

  Future<String?> updateMotor(
    String motorId,
    String name,
    String brand,
    String userId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("${AppConfig.baseUrl}/api/motorcycles/$motorId"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({"_method": "PUT", "name": name, "brand": brand}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        await fetchActiveMotor(userId);
        return null;
      }
      return 'Gagal memperbarui data motor di server.';
    } catch (e) {
      return 'Terjadi kesalahan koneksi database.';
    }
  }

  Future<String?> deleteMotor(String motorId, String userId) async {
    try {
      final response = await http
          .delete(Uri.parse("${AppConfig.baseUrl}/api/motorcycles/$motorId"))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        _motors.removeWhere((m) => m.id == motorId);
        if (_selectedMotorId == motorId) {
          _selectedMotorId = null;
        }
        await fetchActiveMotor(userId);
        return null;
      }
      return 'Gagal menghapus motor dari server.';
    } catch (e) {
      return 'Terjadi kesalahan koneksi database.';
    }
  }
}
