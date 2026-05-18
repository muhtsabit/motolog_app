// lib/models/motor_model.dart

class MotorModel {
  final String id;
  final String userId;
  final String name;
  final String brand;
  final int currentKm;
  final String? plateNumber;
  final String? color;
  final DateTime createdAt;

  const MotorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.brand,
    required this.currentKm,
    this.plateNumber,
    this.color,
    required this.createdAt,
  });

  MotorModel copyWith({
    String? name,
    String? brand,
    int? currentKm,
    String? plateNumber,
    String? color,
  }) {
    return MotorModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      currentKm: currentKm ?? this.currentKm,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'name': name,
    'brand': brand,
    'currentKm': currentKm,
    'plateNumber': plateNumber,
    'color': color,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MotorModel.fromMap(Map<String, dynamic> map) => MotorModel(
    id: map['id'],
    userId: map['userId'],
    name: map['name'],
    brand: map['brand'],
    currentKm: map['currentKm'],
    plateNumber: map['plateNumber'],
    color: map['color'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}
