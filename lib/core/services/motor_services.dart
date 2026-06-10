import '../../models/motor_model.dart';

class MotorService {
  MotorService._();
  static final MotorService instance = MotorService._();
  final List<MotorModel> _motors = [];
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

  Future<List<MotorModel>> getMotors(String userId) async {
    await _delay();
    return _motors.where((m) => m.userId == userId).toList();
  }

  Future<MotorModel> addMotor(MotorModel motor) async {
    await _delay();
    _motors.add(motor);
    return motor;
  }

  Future<MotorModel> updateMotor(MotorModel motor) async {
    await _delay();
    final idx = _motors.indexWhere((m) => m.id == motor.id);
    if (idx != -1) _motors[idx] = motor;
    return motor;
  }

  Future<void> deleteMotor(String motorId) async {
    await _delay();
    _motors.removeWhere((m) => m.id == motorId);
  }

  Future<void> updateKm(String motorId, int newKm) async {
    await _delay();
    final idx = _motors.indexWhere((m) => m.id == motorId);
    if (idx != -1) {
      _motors[idx] = _motors[idx].copyWith(currentKm: newKm);
    }
  }

  Future<bool> hasMotor(String userId) async {
    await _delay(ms: 300);
    return _motors.any((m) => m.userId == userId);
  }

  Future<void> _delay({int ms = 600}) async =>
      Future.delayed(Duration(milliseconds: ms));
}
