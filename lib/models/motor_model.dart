class MotorModel {
  final String id;
  final String userId;
  final String name;
  final String brand;
  final int currentKm;
  final String? plateNumber;
  final String? color;
  final DateTime createdAt;
  final Map<String, int> componentLastServices;

  const MotorModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.brand,
    required this.currentKm,
    this.plateNumber,
    this.color,
    required this.createdAt,
    required this.componentLastServices,
  });

  MotorModel copyWith({
    String? userId,
    String? name,
    String? brand,
    int? currentKm,
    String? plateNumber,
    String? color,
    Map<String, int>? componentLastServices,
  }) {
    return MotorModel(
      id: id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      currentKm: currentKm ?? this.currentKm,
      plateNumber: plateNumber ?? this.plateNumber,
      color: color ?? this.color,
      createdAt: createdAt,
      componentLastServices:
          componentLastServices ?? this.componentLastServices,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'brand': brand,
    'current_km': currentKm,
    'plate_number': plateNumber,
    'color': color,
    'created_at': createdAt.toIso8601String(),
    'component_last_services': componentLastServices,
  };

  factory MotorModel.fromMap(Map<String, dynamic> map) {
    final rawComponents =
        map['component_last_services'] ?? map['componentLastServices'] ?? {};
    final Map<String, int> normalizedComponents = {};

    if (rawComponents is Map) {
      rawComponents.forEach((key, value) {
        normalizedComponents[key.toString()] = value is int
            ? value
            : (int.tryParse(value.toString()) ?? 0);
      });
    }

    return MotorModel(
      id: map['id'].toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      currentKm: map['current_km'] ?? map['currentKm'] ?? 0,
      plateNumber: map['plate_number'] ?? map['plateNumber'],
      color: map['color'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : (map['createdAt'] != null
                ? DateTime.parse(map['createdAt'])
                : DateTime.now()),
      componentLastServices: normalizedComponents,
    );
  }
}
