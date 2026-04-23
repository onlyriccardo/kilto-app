import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/client/home');
            }
          },
        ),
        title: const Text('Notificaciones'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _onMarkAll,
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
      body: kDemoMode ? _demoBody() : _realBody(),
    );
  }

  // ── Demo path (reads from DemoData, local state toggles) ────────────
  late final List<_DemoNotif> _demoItems = DemoData.notifications
      .map((n) => _DemoNotif(
            icon: Icons.notifications_outlined,
            iconColor: (n['unread'] as bool)
                ? KiltoColors.teal
                : KiltoColors.greyText,
            title: (n['icon'] as String),
            body: n['text'] as String,
            time: n['time'] as String,
            isRead: !(n['unread'] as bool),
          ))
      .toList();

  Widget _demoBody() {
    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      color: KiltoColors.teal,
      child: _demoItems.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _demoItems.length,
              itemBuilder: (_, i) {
                final n = _demoItems[i];
                return _tile(
                  isRead: n.isRead,
                  icon: n.icon,
                  iconColor: n.iconColor,
                  title: n.title,
                  body: n.body,
                  time: n.time,
                  onTap: () => setState(() => n.isRead = true),
                );
              },
            ),
    );
  }

  // ── Real path ───────────────────────────────────────────────────────
  Widget _realBody() {
    final async = ref.watch(notificationsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _errorState(e.toString()),
      data: (items) => RefreshIndicator(
        color: KiltoColors.teal,
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: 100), _buildEmptyState()],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return _tile(
                    isRead: n.read,
                    icon: _iconFor(n.icon),
                    iconColor: _iconColor(n.read),
                    title: n.title,
                    body: n.body ?? '',
                    time: _formatTime(n.createdAt),
                    onTap: () => _onMarkRead(n),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _onMarkRead(NotificationItem n) async {
    if (n.read) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(notificationsServiceProvider).markRead(n.id);
      ref.invalidate(notificationsProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _onMarkAll() async {
    if (kDemoMode) {
      setState(() {
        for (final n in _demoItems) {
          n.isRead = true;
        }
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(notificationsServiceProvider).markAllRead();
      ref.invalidate(notificationsProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  IconData _iconFor(String? code) {
    switch (code) {
      case 'calendar':
      case 'appointment':
        return Icons.calendar_today_rounded;
      case 'document':
        return Icons.description_outlined;
      case 'promotion':
        return Icons.local_offer_outlined;
      case 'check':
        return Icons.check_circle_outline;
      case 'reminder':
        return Icons.notifications_active;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(bool read) =>
      read ? KiltoColors.greyText : KiltoColors.teal;

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _tile({
    required bool isRead,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isRead
              ? KiltoColors.white
              : KiltoColors.teal.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? KiltoColors.greyMid
                : KiltoColors.teal.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRead)
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isRead ? FontWeight.w600 : FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 12,
                        color: KiltoColors.greyText,
                      ),
                    ),
                  ],
                  if (time.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        color: KiltoColors.greyText.withOpacity(0.7),
                      ),
                    ),
                  ],
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
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              style:
                  TextStyle(fontSize: 13, color: KiltoColors.greyText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: KiltoColors.greyText),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar las notificaciones',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(notificationsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
}

class _DemoNotif {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isRead;
  _DemoNotif({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
