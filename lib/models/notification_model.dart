import 'package:flutter/material.dart';

enum NotificationType { critical, warning, info }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime dateTime;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.dateTime,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case NotificationType.critical:
        return Icons.error_rounded;
      case NotificationType.warning:
        return Icons.warning_rounded;
      case NotificationType.info:
        return Icons.lightbulb_rounded;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.critical:
        return const Color(0xFFF04438); // Merah / Danger
      case NotificationType.warning:
        return const Color(0xFFFF6B2C); // Oranye / Warning
      case NotificationType.info:
        return const Color(0xFF2BBCD4); // Teal / Primary
    }
  }
}
