import 'package:biztidy_agent_app/app/helpers/agent_sharedprefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AgentNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'job', 'approval', 'rating', 'system'
  final DateTime createdAt;
  bool isRead;

  AgentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory AgentNotification.fromJson(Map<String, dynamic> json) =>
      AgentNotification(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        type: json['type'] ?? 'system',
        createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: json['isRead'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': Timestamp.fromDate(createdAt),
        'isRead': isRead,
      };
}

class AgentNotificationsController extends GetxController {
  List<AgentNotification> notifications = [];
  bool showLoading = false;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    showLoading = true;
    update();
    final agent = await getLocallySavedAgentDetails();
    if (agent?.agentId != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('Agents')
            .doc(agent!.agentId)
            .collection('Notifications')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();
        notifications = snapshot.docs
            .map((d) => AgentNotification.fromJson(d.data()))
            .toList();
      } catch (_) {
        // No notifications yet — show welcome notification
        notifications = [
          AgentNotification(
            id: 'welcome',
            title: 'Welcome to BizTidy Agent!',
            body: 'Your account is set up. Go online to start receiving jobs.',
            type: 'system',
            createdAt: DateTime.now(),
            isRead: false,
          ),
        ];
      }
    }
    showLoading = false;
    update();
  }

  Future<void> markAllRead() async {
    final agent = await getLocallySavedAgentDetails();
    // Mark all as read locally first for instant UI response
    for (final n in notifications) {
      n.isRead = true;
    }
    update();
    // Then batch-write to Firestore in a single round trip
    if (agent?.agentId != null) {
      final batch = FirebaseFirestore.instance.batch();
      for (final n in notifications) {
        if (n.id != 'welcome') {
          final ref = FirebaseFirestore.instance
              .collection('Agents')
              .doc(agent!.agentId)
              .collection('Notifications')
              .doc(n.id);
          batch.update(ref, {'isRead': true});
        }
      }
      await batch.commit();
    }
  }

  Future<void> markRead(AgentNotification notification) async {
    notification.isRead = true;
    final agent = await getLocallySavedAgentDetails();
    if (agent?.agentId != null && notification.id != 'welcome') {
      await FirebaseFirestore.instance
          .collection('Agents')
          .doc(agent!.agentId)
          .collection('Notifications')
          .doc(notification.id)
          .update({'isRead': true});
    }
    update();
  }

  Future<void> reloadNotifications() => _loadNotifications();
}
