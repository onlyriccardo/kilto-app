import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_text.dart';

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
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/client/home'),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: KiltoColors.zinc900),
                    style: IconButton.styleFrom(
                      backgroundColor: KiltoColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(KiltoRadii.xsmall),
                        side: const BorderSide(color: KiltoColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KiltoText.label('Tu clínica'),
                        KiltoText.h3('Notificaciones'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _onMarkAll,
                    style: TextButton.styleFrom(
                      foregroundColor: KiltoColors.zinc950,
                      textStyle: const TextStyle(
                        fontFamily: KiltoFonts.familyHeading,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Marcar todo'),
                  ),
                ],
              ),
            ),
            Expanded(child: kDemoMode ? _demoBody() : _realBody()),
          ],
        ),
      ),
    );
  }

  // ── Demo path (reads from DemoData, local state toggles) ────────────
  late final List<_DemoNotif> _demoItems = DemoData.notifications
      .map((n) => _DemoNotif(
            title: (n['icon'] as String),
            body: n['text'] as String,
            time: n['time'] as String,
            isRead: !(n['unread'] as bool),
          ))
      .toList();

  Widget _demoBody() {
    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      child: _demoItems.isEmpty
          ? _empty()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: _demoItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _demoItems[i];
                return _NotifTile(
                  icon: Icons.notifications_outlined,
                  title: n.title,
                  body: n.body,
                  time: n.time,
                  isRead: n.isRead,
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
        onRefresh: () async => ref.invalidate(notificationsProvider),
        child: items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [const SizedBox(height: 80), _empty()],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final n = items[i];
                  return _NotifTile(
                    icon: _iconFor(n.icon),
                    title: n.title,
                    body: n.body ?? '',
                    time: _formatTime(n.createdAt),
                    isRead: n.read,
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

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Widget _empty() => KiltoEmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'Sin notificaciones',
        subtitle: 'No tienes notificaciones pendientes.',
      );

  Widget _errorState(String msg) => KiltoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudieron cargar las notificaciones',
        subtitle: msg,
        actionLabel: 'Reintentar',
        onAction: () => ref.invalidate(notificationsProvider),
      );
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final VoidCallback onTap;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;
    final radius = BorderRadius.circular(KiltoRadii.medium);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isRead
                ? KiltoColors.surface
                : Color.alphaBlend(
                    accent.withValues(alpha: 0.05), Colors.white),
            borderRadius: radius,
            border: Border.all(
              color: isRead
                  ? KiltoColors.border
                  : accent.withValues(alpha: 0.28),
              width: 1,
            ),
            boxShadow: KiltoShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 10,
                  child: Center(
                    child: isRead
                        ? const SizedBox.shrink()
                        : Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isRead
                        ? KiltoColors.zinc100
                        : accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                  ),
                  child: Icon(
                    icon,
                    color: isRead ? KiltoColors.zinc500 : accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KiltoText.strong(title, size: 13.5),
                      if (body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        KiltoText.body(body,
                            size: 12, color: KiltoColors.zinc600),
                      ],
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        KiltoText.label(time,
                            size: 10.5, color: KiltoColors.zinc400),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoNotif {
  final String title;
  final String body;
  final String time;
  bool isRead;
  _DemoNotif({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });
}
