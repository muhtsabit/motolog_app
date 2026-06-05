// lib/features/notification/notification_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Notification Screen — MotoLog (Local Fallback Version untuk Keperluan Testing)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../dashboard/widgets/dashboard_bottom_nav.dart';

// Model Tiruan Lokal khusus pencegahan error compile sebelum modul FCM dipasang
class LocalNotifModel {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final IconData icon;
  final Color color;
  bool isRead;

  LocalNotifModel({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final int _selectedNav = 3; // Tab Notifikasi Aktif

  // List data dummy lokal biar halaman ga kosong pas di-demo / di-test
  final List<LocalNotifModel> _localNotifications = [
    LocalNotifModel(
      id: '1',
      title: 'Waktunya Ganti Oli! 🛠️',
      message: 'Oli Mesin Anda sudah melewati batas pemakaian berkala.',
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      icon: Icons.opacity_rounded,
      color: Colors.amber,
    ),
    LocalNotifModel(
      id: '2',
      title: 'Kondisi Busi Prima 👍',
      message: 'Catatan servis busi Anda berhasil diperbarui di database.',
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      icon: Icons.electric_bolt_rounded,
      color: Colors.green,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    // Hitung jumlah yang belum dibaca secara internal
    final hasUnread = _localNotifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── AppBar Gradient ───────────────────────────
          _NotificationAppBar(
            hPad: hPad,
            hasUnread: hasUnread,
            onReadAll: () {
              setState(() {
                for (var n in _localNotifications) {
                  n.isRead = true;
                }
              });
            },
          ),

          // ── Main Content ──────────────────────────────
          Expanded(
            child: _localNotifications.isEmpty
                ? const _EmptyNotificationState()
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      AppConstants.spaceMD,
                      hPad,
                      MediaQuery.paddingOf(context).bottom +
                          AppConstants.spaceLG,
                    ),
                    itemCount: _localNotifications.length,
                    itemBuilder: (context, i) {
                      final notif = _localNotifications[i];
                      return _NotificationCard(
                        notification: notif,
                        onTap: () {
                          setState(() {
                            notif.isRead = true;
                          });
                        },
                      );
                    },
                  ),
          ),

          // ── Bottom Navigation Bar ─────────────────────
          DashboardBottomNav(selectedIndex: _selectedNav),
        ],
      ),
    );
  }
}

class _NotificationAppBar extends StatelessWidget {
  final double hPad;
  final bool hasUnread;
  final VoidCallback onReadAll;

  const _NotificationAppBar({
    required this.hPad,
    required this.hasUnread,
    required this.onReadAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2BBCD4), Color(0xFF1272AE)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppConstants.spaceXS,
        MediaQuery.paddingOf(context).top + AppConstants.spaceXS,
        16,
        AppConstants.spaceMD,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Pemberitahuan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pantau kesehatan part motor Anda',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (hasUnread)
            TextButton.icon(
              onPressed: onReadAll,
              icon: const Icon(
                Icons.done_all_rounded,
                color: Colors.white,
                size: 14,
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              label: const Text(
                'Tandai Dibaca',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final LocalNotifModel notification;
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
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notification.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: AppColors.textPrimary,
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
