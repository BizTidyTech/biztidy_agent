// ignore_for_file: prefer_const_constructors
import 'package:biztidy_agent_app/ui/features_agent/agent_notifications/agent_notifications_controller/agent_notifications_controller.dart';
import 'package:biztidy_agent_app/ui/shared/loading_widget.dart';
import 'package:biztidy_agent_app/ui/shared/spacer.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_colors.dart';
import 'package:biztidy_agent_app/utils/app_constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Cached shadow — prevents allocating a new List+BoxShadow on every card rebuild
final _cardShadow = [
  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
];
final _notifDateFmt = DateFormat('MMM d');

class AgentNotificationsView extends StatefulWidget {
  const AgentNotificationsView({super.key});

  @override
  State<AgentNotificationsView> createState() => _AgentNotificationsViewState();
}

class _AgentNotificationsViewState extends State<AgentNotificationsView> {
  late final AgentNotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AgentNotificationsController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AgentNotificationsController>(
      builder: (_) {
        // No Scaffold here — this renders inside a DraggableScrollableSheet
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text('Notifications',
                      style: AppStyles.keyStringStyle(18, AppColors.fullBlack)),
                  const Spacer(),
                  if (controller.unreadCount > 0)
                    TextButton(
                      onPressed: controller.markAllRead,
                      child: Text('Mark all read',
                          style: AppStyles.subStringStyle(
                              13, AppColors.primaryThemeColor)),
                    ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppColors.darkGray),
                    onPressed: controller.reloadNotifications,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: controller.showLoading
                  ? loadingWidget()
                  : controller.notifications.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          onRefresh: controller.reloadNotifications,
                          color: AppColors.primaryThemeColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.notifications.length,
                            itemBuilder: (_, i) {
                              final n = controller.notifications[i];
                              return _notificationCard(context, n, controller);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _notificationCard(BuildContext context, AgentNotification n,
      AgentNotificationsController controller) {
    final iconData = _iconForType(n.type);
    final iconColor = _colorForType(n.type);
    final timeAgo = _timeAgo(n.createdAt);

    return GestureDetector(
      onTap: () => controller.markRead(n),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead
              ? AppColors.plainWhite
              : AppColors.primaryThemeColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.isRead
                ? Colors.grey.shade200
                : AppColors.primaryThemeColor.withValues(alpha: 0.3),
          ),
          boxShadow: _cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: AppStyles.regularStringStyle(
                              14,
                              n.isRead
                                  ? AppColors.darkGray
                                  : AppColors.fullBlack),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primaryThemeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  verticalSpacer(4),
                  Text(
                    n.body,
                    style: AppStyles.subStringStyle(13, AppColors.darkGray),
                  ),
                  verticalSpacer(6),
                  Text(
                    timeAgo,
                    style: AppStyles.subStringStyle(11, AppColors.darkGray
                        .withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 56, color: AppColors.darkGray),
            verticalSpacer(12),
            Text('No notifications yet',
                style: AppStyles.subStringStyle(15, AppColors.darkGray)),
            verticalSpacer(6),
            Text('You\'ll be notified about new jobs and updates here',
                style: AppStyles.subStringStyle(13, AppColors.darkGray),
                textAlign: TextAlign.center),
          ],
        ),
      );

  IconData _iconForType(String type) {
    switch (type) {
      case 'job':
        return Icons.work_outline;
      case 'approval':
        return Icons.verified_outlined;
      case 'rating':
        return Icons.star_outline;
      default:
        return Icons.info_outline;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'job':
        return AppColors.primaryThemeColor;
      case 'approval':
        return AppColors.normalGreen;
      case 'rating':
        return Colors.amber;
      default:
        return Colors.blueGrey;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _notifDateFmt.format(dt);
  }
}
