// lib/features/notification/widgets/notification_app_bar.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_routes.dart';

class NotificationAppBar extends StatelessWidget {
  final double hPad;
  final bool hasUnread;
  final VoidCallback onReadAll;

  const NotificationAppBar({
    super.key,
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
                  onPressed: () {
                    // Gunakan pushReplacement agar tidak blank saat pop
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.dashboard,
                      );
                    }
                  },
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
