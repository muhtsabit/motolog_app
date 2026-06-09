// lib/features/notification/notification_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_services.dart';
import '../../core/constants/app_config.dart';
import '../dashboard/widgets/dashboard_bottom_nav.dart';
import 'widgets/notification_app_bar.dart'; // ← widget eksternal

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final IconData icon;
  final Color color;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.icon,
    required this.color,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final titleText = json['title']?.toString().toLowerCase() ?? '';
    IconData itemIcon = Icons.notifications_active_rounded;
    Color itemColor = Colors.blue;

    if (titleText.contains('oli')) {
      itemIcon = Icons.opacity_rounded;
      itemColor = Colors.amber;
    } else if (titleText.contains('busi')) {
      itemIcon = Icons.electric_bolt_rounded;
      itemColor = Colors.green;
    } else if (titleText.contains('rem')) {
      itemIcon = Icons.album_rounded;
      itemColor = Colors.orange;
    }

    // ◄── FIX: MAPPING PROPERTI DIBAWAH INI DISESUAIKAN DENGAN DATABASE MYSQL ──►
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? 'Pemberitahuan MotoLog',
      message:
          json['message'] ??
          json['body'] ??
          '', // ◄── message diutamakan dibanding body
      dateTime: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      icon: itemIcon,
      color: itemColor,
      // Handle tipe data boolean MySQL (bisa berupa int 1/0 atau true/false string)
      isRead:
          json['is_read'] == 1 ||
          json['is_read'] == true ||
          json['is_read'] == '1',
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final int _selectedNav = 3;
  late Future<List<NotificationModel>> _fetchNotificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final userId = context.read<AuthService>().currentUser?.id ?? '';
    _fetchNotificationsFuture = _getNotificationsFromBackend(userId);
  }

  Future<List<NotificationModel>> _getNotificationsFromBackend(
    String userId,
  ) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/api/notifications/$userId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((jsonItem) => NotificationModel.fromJson(jsonItem))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("=== MOLOG ERROR: Gagal muat riwayat notifikasi ($e) ===");
      return [];
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = context.read<AuthService>().currentUser?.id ?? '';
    try {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/notifications/read-all/$userId'),
      );
      setState(() {
        _loadNotifications();
      });
    } catch (e) {
      debugPrint("=== MOLOG ERROR: Gagal tandai dibaca ($e) ===");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          FutureBuilder<List<NotificationModel>>(
            future: _fetchNotificationsFuture,
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              final hasUnread = list.any((n) => !n.isRead);

              // ← PAKAI WIDGET EKSTERNAL (bukan class private lagi)
              return NotificationAppBar(
                hPad: hPad,
                hasUnread: hasUnread,
                onReadAll: _markAllAsRead,
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<NotificationModel>>(
              future: _fetchNotificationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return const _EmptyNotificationState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _loadNotifications();
                    });
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      AppConstants.spaceMD,
                      hPad,
                      MediaQuery.paddingOf(context).bottom +
                          AppConstants.spaceLG,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, i) {
                      final notif = notifications[i];
                      return _NotificationCard(
                        notification: notif,
                        onTap: () async {
                          if (!notif.isRead) {
                            await http.post(
                              Uri.parse(
                                '${AppConfig.baseUrl}/api/notifications/read/${notif.id}',
                              ),
                            );
                            setState(() {
                              notif.isRead = true;
                            });
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          DashboardBottomNav(selectedIndex: _selectedNav),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: AppConstants.spaceSM),
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : const Color(0xFF2BBCD4).withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : const Color(0xFF2BBCD4).withOpacity(0.2),
            width: notification.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 20,
              ),
            ),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2BBCD4),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat(
                      'd MMM yyyy, HH:mm',
                      'id_ID',
                    ).format(notification.dateTime),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textDisabled,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotificationState extends StatelessWidget {
  const _EmptyNotificationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLG),
            const Text(
              'Belum Ada Notifikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Semua pemberitahuan kondisi komponen motor Anda akan muncul di halaman ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
