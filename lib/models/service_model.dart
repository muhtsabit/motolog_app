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

  // Getter otomatis untuk mencocokkan Icon berdasarkan nama komponen di UI
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

  // Siap dikirim ke backend Laravel dalam bentuk JSON / Form-Data
  Map<String, dynamic> toMap() => {
    'id': id,
    'motorId': motorId,
    'userId': userId,
    'componentName': componentName,
    'serviceDate': serviceDate.toIso8601String(),
    'serviceKm': serviceKm,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  // Siap memetakan response JSON dari API Laravel
  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
    id: map['id'],
    motorId: map['motorId'],
    userId: map['userId'],
    componentName: map['componentName'],
    serviceDate: DateTime.parse(map['serviceDate']),
    serviceKm: map['serviceKm'],
    notes: map['notes'],
    createdAt: DateTime.parse(map['createdAt']),
  );
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
