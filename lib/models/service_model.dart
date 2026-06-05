// lib/models/service_model.dart

import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String motorId;
  final String userId;
  final String componentName;
  final DateTime serviceDate;
  final int serviceKm;
  final String? notes;
  final DateTime createdAt;

  const ServiceModel({
    required this.id,
    required this.motorId,
    required this.userId,
    required this.componentName,
    required this.serviceDate,
    required this.serviceKm,
    this.notes,
    required this.createdAt,
  });

  IconData get componentIcon {
    final match = kComponentOptions.firstWhere(
      (element) => element.name.toLowerCase() == componentName.toLowerCase(),
      orElse: () =>
          const ComponentOption(name: 'Lainnya', icon: Icons.build_rounded),
    );
    return match.icon;
  }

  ServiceModel copyWith({
    String? componentName,
    DateTime? serviceDate,
    int? serviceKm,
    String? notes,
  }) {
    return ServiceModel(
      id: id,
      motorId: motorId,
      userId: userId,
      componentName: componentName ?? this.componentName,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceKm: serviceKm ?? this.serviceKm,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'motor_id': motorId,
    'user_id': userId,
    'component_name': componentName,
    'service_date': serviceDate.toIso8601String(),
    'service_km': serviceKm,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  // ◄── FIX MUTLAK TUBES: Pemetaan Fleksibel membaca JSON murni MySQL Laravel ──►
  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'].toString(),
      motorId: (map['motorcycle_id'] ?? map['motor_id'] ?? map['motorId'] ?? '')
          .toString(),
      userId: (map['user_id'] ?? map['userId'] ?? '').toString(),
      componentName:
          map['component_name'] ?? map['componentName'] ?? 'Servis Rutin',
      serviceDate: map['service_date'] != null
          ? DateTime.parse(map['service_date'])
          : DateTime.parse(
              map['serviceDate'] ?? DateTime.now().toIso8601String(),
            ),
      serviceKm: map['service_km'] ?? map['serviceKm'] ?? 0,
      notes: map['notes'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.parse(
              map['createdAt'] ?? DateTime.now().toIso8601String(),
            ),
    );
  }
}

class ComponentOption {
  final String name;
  final IconData icon;
  const ComponentOption({required this.name, required this.icon});
}

const kComponentOptions = [
  ComponentOption(name: 'Oli Mesin', icon: Icons.opacity_rounded),
  ComponentOption(name: 'Filter Udara', icon: Icons.air_rounded),
  ComponentOption(name: 'Busi', icon: Icons.electric_bolt_rounded),
  ComponentOption(name: 'Kampas Rem', icon: Icons.album_rounded),
  ComponentOption(name: 'Rantai', icon: Icons.link_rounded),
  ComponentOption(name: 'Ban Depan', icon: Icons.circle_outlined),
  ComponentOption(name: 'Ban Belakang', icon: Icons.circle_outlined),
  ComponentOption(name: 'Aki', icon: Icons.battery_charging_full_rounded),
  ComponentOption(name: 'Karburator', icon: Icons.settings_rounded),
  ComponentOption(name: 'Lainnya', icon: Icons.build_rounded),
];
