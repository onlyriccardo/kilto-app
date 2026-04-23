import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Staff-scoped notifications. Fetched from /v1/clinic/notifications.
class ClinicNotificationsScreen extends ConsumerWidget {
  const ClinicNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicNotificationsProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Notificaciones'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar las notificaciones\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (notifications) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(clinicNotificationsProvider),
          child: notifications.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No tienes notificaciones.',
                          style: TextStyle(color: KiltoColors.greyText),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, i) {
                    final n = notifications[i];
                    final isUnread = n['unread'] == true;
                    final accent = Theme.of(context).colorScheme.primary;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? Color.alphaBlend(
                                accent.withOpacity(0.08), Colors.white)
                            : KiltoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KiltoColors.greyMid),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              margin:
                                  const EdgeInsets.only(top: 6, right: 8),
                              decoration: BoxDecoration(
                                  color: accent, shape: BoxShape.circle),
                            )
                          else
                            const SizedBox(width: 16),
                          Text(n['icon'] as String? ?? '🔔',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(n['title'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: KiltoColors.navy)),
                                if ((n['body'] as String? ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(n['body'] as String,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: KiltoColors.greyText)),
                                ],
                                const SizedBox(height: 4),
                                Text(n['time_label'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: KiltoColors.greyText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
