import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final List<_NotificationItem> _notifications = kDemoMode
      ? DemoData.notifications.map((n) => _NotificationItem(
            icon: Icons.notifications_outlined,
            iconColor: (n['unread'] as bool) ? KiltoColors.teal : KiltoColors.greyText,
            title: (n['icon'] as String),
            body: n['text'] as String,
            time: n['time'] as String,
            isRead: !(n['unread'] as bool),
          )).toList()
      : [
          _NotificationItem(
            icon: Icons.calendar_today,
            iconColor: KiltoColors.teal,
            title: 'Cita confirmada',
            body: 'Tu cita de limpieza dental el 15 Abr a las 10:00 AM ha sido confirmada.',
            time: 'Hace 2 horas',
            isRead: false,
          ),
          _NotificationItem(
            icon: Icons.description_outlined,
            iconColor: KiltoColors.blue,
            title: 'Nuevo documento',
            body: 'Se ha subido una nueva radiografía a tu expediente.',
            time: 'Hace 1 día',
            isRead: false,
          ),
          _NotificationItem(
            icon: Icons.notifications_active,
            iconColor: KiltoColors.yellow,
            title: 'Recordatorio',
            body: 'No olvides tu cita de control el miércoles 17 Abr.',
            time: 'Hace 2 días',
            isRead: true,
          ),
          _NotificationItem(
            icon: Icons.local_offer_outlined,
            iconColor: KiltoColors.green,
            title: 'Promoción especial',
            body: '20% de descuento en blanqueamiento dental este mes.',
            time: 'Hace 5 días',
            isRead: true,
          ),
          _NotificationItem(
            icon: Icons.check_circle_outline,
            iconColor: KiltoColors.teal,
            title: 'Cita completada',
            body: 'Tu cita de limpieza dental del 28 Mar ha sido registrada como completada.',
            time: 'Hace 2 semanas',
            isRead: true,
          ),
        ];

  Future<void> _onRefresh() async {
    // Simulate refresh
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notificaciones'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (final n in _notifications) {
                  n.isRead = true;
                }
              });
            },
            child: const Text(
              'Marcar todo',
              style: TextStyle(
                fontSize: 13,
                color: KiltoColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: KiltoColors.teal,
        child: _notifications.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return _buildNotificationTile(notification);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationTile(_NotificationItem notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          notification.isRead = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? KiltoColors.white
              : KiltoColors.teal.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? KiltoColors.greyMid
                : KiltoColors.teal.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: KiltoColors.teal,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16),
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: notification.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 12,
                      color: KiltoColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: KiltoColors.greyText.withOpacity(0.7),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: KiltoColors.greyText.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin notificaciones',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No tienes notificaciones pendientes',
            style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isRead;

  _NotificationItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
