// lib/features/service/service_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/state/app_state.dart';
import '../../models/service_model.dart';
import 'widgets/service_history_app_bar.dart'; // ← widget eksternal

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final int _selectedNav = 1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeMotor = context.read<AppState>().activeMotor;
      if (activeMotor != null) {
        context.read<AppState>().fetchServiceHistories(activeMotor.id);
      }
    });
  }

  void _onDeleteService(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Data servis ini akan dihapus permanen.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Fitur hapus dinonaktifkan demi integritas data KM.',
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _onEditService(ServiceModel service) {
    Navigator.pushNamed(
      context,
      AppRoutes.addService,
      arguments: {'editService': service},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth > 520 ? 480.0 : screenWidth - 32.0;
    final hPad = (screenWidth - contentWidth) / 2;

    final appState = context.watch<AppState>();
    final services = appState.serviceHistories;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ← PAKAI WIDGET EKSTERNAL (bukan class private lagi)
          ServiceHistoryAppBar(hPad: hPad, contentWidth: contentWidth),
          Expanded(
            child: appState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : services.isEmpty
                ? _EmptyServiceState(
                    onAddService: () =>
                        Navigator.pushNamed(context, AppRoutes.addService),
                  )
                : _ServiceTimeline(
                    services: services,
                    hPad: hPad,
                    contentWidth: contentWidth,
                    onEdit: _onEditService,
                    onDelete: _onDeleteService,
                  ),
          ),
          _HistoryBottomNav(
            selectedIndex: _selectedNav,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
              }
              if (i == 2) Navigator.pushNamed(context, AppRoutes.addService);
              if (i == 3) Navigator.pushNamed(context, AppRoutes.reminder);
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceTimeline extends StatelessWidget {
  final List<ServiceModel> services;
  final double hPad;
  final double contentWidth;
  final void Function(ServiceModel) onEdit;
  final void Function(String) onDelete;

  const _ServiceTimeline({
    required this.services,
    required this.hPad,
    required this.contentWidth,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        hPad,
        AppConstants.spaceMD,
        hPad,
        MediaQuery.paddingOf(context).bottom + AppConstants.spaceLG,
      ),
      itemCount: services.length,
      itemBuilder: (_, i) => _TimelineItem(
        service: services[i],
        isLast: i == services.length - 1,
        onEdit: () => onEdit(services[i]),
        onDelete: () => onDelete(services[i].id),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ServiceModel service;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.service,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    const dotSize = 12.0;
    const lineWidth = 2.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: dotSize + 16,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    top: dotSize,
                    bottom: 0,
                    left: (dotSize / 2) - (lineWidth / 2) + 8,
                    child: Container(
                      width: lineWidth,
                      color: AppColors.primary.withOpacity(0.35),
                    ),
                  ),
                Positioned(
                  top: AppConstants.spaceMD,
                  left: 8,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceSM),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spaceMD),
              child: _ServiceCard(
                service: service,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getComponentIcon(String name) {
    switch (name) {
      case 'Oli Mesin':
        return Icons.opacity_rounded;
      case 'Busi':
        return Icons.electric_bolt_rounded;
      case 'Kampas Rem':
        return Icons.album_rounded;
      case 'Filter Udara':
        return Icons.air_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getComponentIcon(service.componentName),
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppConstants.spaceSM),
              Expanded(
                child: Text(
                  service.componentName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outlined,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
                child: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXS),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('d MMM yyyy', 'id_ID').format(service.serviceDate),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppConstants.spaceMD),
              const Icon(
                Icons.speed_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${service.serviceKm.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+$)"), (m) => "${m[1]}.")} KM',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (service.notes != null && service.notes!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.spaceXS),
            Text(
              service.notes!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyServiceState extends StatelessWidget {
  final VoidCallback onAddService;
  const _EmptyServiceState({required this.onAddService});

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
                color: AppColors.primaryLight.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLG),
            const Text(
              'Belum Ada Riwayat Servis',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXS),
            const Text(
              'Catat servis pertama motor Anda\nuntuk mulai tracking perawatan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onAddService,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Catat Servis Pertama',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;
  const _HistoryBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Beranda'),
      (Icons.history_rounded, 'Riwayat'),
      (Icons.add_circle_rounded, 'Tambah'),
      (Icons.notifications_outlined, 'Notifikasi'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = selectedIndex == i;
              final color = selected
                  ? AppColors.primary
                  : AppColors.textDisabled;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i].$1, color: color, size: 24),
                      const SizedBox(height: 3),
                      Text(
                        items[i].$2,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
