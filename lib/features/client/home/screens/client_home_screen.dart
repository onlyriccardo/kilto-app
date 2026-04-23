import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/auth/auth_state.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final userName = kDemoMode ? DemoData.user['name'] as String : (auth.userName ?? 'U');
    final initials = kDemoMode ? DemoData.user['initials'] as String : _getInitials(userName);
    final firstName = kDemoMode ? DemoData.user['first_name'] as String : (auth.userName?.split(' ').first ?? 'Usuario');
    final tenantName = kDemoMode ? DemoData.tenant['name'] as String : (auth.tenantName ?? 'Clínica');

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(appointmentsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(context, initials, firstName, tenantName),
                const SizedBox(height: 24),
                _buildNextAppointmentCard(context, ref),
                const SizedBox(height: 24),
                const Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildHealthTipCard(),
                const SizedBox(height: 24),
                const Text(
                  'Actividad reciente',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentActivity(ref),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String initials, String firstName, String tenantName) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            initials,
            style: const TextStyle(
              color: KiltoColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola, $firstName \u{1F44B}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
              Text(
                tenantName,
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/client/notifications'),
          icon: const Icon(
            Icons.notifications_outlined,
            color: KiltoColors.navy,
            size: 26,
          ),
        ),
      ],
    );
  }

  // ── Next appointment card (real data aware) ───────────────────────
  Widget _buildNextAppointmentCard(BuildContext context, WidgetRef ref) {
    if (kDemoMode) {
      final demo = DemoData.upcomingAppointments.first;
      return _nextAppointmentShell(
        context: context,
        service: demo['service'] as String,
        dateLabel: demo['date'] as String,
        timeLabel: demo['time'] as String,
        doctor: demo['doctor'] as String,
        onConfirm: () {},
      );
    }

    final async = ref.watch(appointmentsProvider);
    return async.when(
      loading: () => _skeletonCard(),
      error: (_, __) => _noUpcomingCard(context),
      data: (res) {
        if (res.upcoming.isEmpty) return _noUpcomingCard(context);
        final apt = res.upcoming.first;
        return _nextAppointmentShell(
          context: context,
          service: apt.service,
          dateLabel: _friendlyDate(apt.date),
          timeLabel: apt.time,
          doctor: apt.staffName ?? 'Profesional',
          onConfirm: apt.status == 'scheduled' ? () => _confirm(context, ref, apt.id) : null,
        );
      },
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref, int id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appointmentsServiceProvider).confirm(id);
      ref.invalidate(appointmentsProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Cita confirmada')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _nextAppointmentShell({
    required BuildContext context,
    required String service,
    required String dateLabel,
    required String timeLabel,
    required String doctor,
    VoidCallback? onConfirm,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2A4A), Color(0xFF2A3D5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: KiltoColors.teal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Próxima cita',
                  style: TextStyle(
                    color: KiltoColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            service,
            style: const TextStyle(
              color: KiltoColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: KiltoColors.teal, size: 15),
              const SizedBox(width: 6),
              Text(dateLabel,
                  style: TextStyle(
                      color: KiltoColors.white.withOpacity(0.8), fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: KiltoColors.teal, size: 15),
              const SizedBox(width: 6),
              Text(timeLabel,
                  style: TextStyle(
                      color: KiltoColors.white.withOpacity(0.8), fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, color: KiltoColors.teal, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(doctor,
                    style: TextStyle(
                        color: KiltoColors.white.withOpacity(0.8),
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: KiltoColors.white,
                    disabledBackgroundColor: KiltoColors.teal.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Confirmar',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/client/appointments'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KiltoColors.white,
                    foregroundColor: KiltoColors.navy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Reagendar',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skeletonCard() => Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: KiltoColors.navy.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );

  Widget _noUpcomingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.event_available_outlined,
              size: 36, color: KiltoColors.teal),
          const SizedBox(height: 12),
          const Text(
            'No tienes citas próximas',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Agenda tu próxima cita en un toque.',
            style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/client/book-appointment'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agendar cita'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: KiltoColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        emoji: '\u{1F4C5}',
        label: 'Nueva cita',
        onTap: () => context.push('/client/book-appointment'),
      ),
      _QuickAction(
        emoji: '\u{1F4CB}',
        label: 'Mi historial',
        onTap: () => context.go('/client/appointments'),
      ),
      _QuickAction(
        emoji: '\u{1F4C1}',
        label: 'Documentos',
        onTap: () => context.go('/client/documents'),
      ),
      _QuickAction(
        emoji: '\u{1F4AC}',
        label: 'Contactar',
        onTap: () => context.push('/client/chat'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: actions.map((action) {
        return GestureDetector(
          onTap: action.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(action.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.navy,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiltoColors.tealLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Text('\u{1F4A1}', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consejo de salud',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.tealDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kDemoMode
                      ? DemoData.healthTip
                      : 'Recuerda cepillar tus dientes al menos 2 veces al día durante 2 minutos.',
                  style: TextStyle(
                    fontSize: 12,
                    color: KiltoColors.navy.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    if (kDemoMode) {
      final items = DemoData.pastAppointments.map((apt) => _ActivityItem(
            title:
                '${apt['service']} - ${apt['status'] == 'completed' ? 'Completada' : apt['status']}',
            subtitle: apt['doctor'] as String,
            date: apt['date'] as String,
            icon: Icons.check_circle_outline,
            iconColor: KiltoColors.green,
          )).toList();
      return _activityList(items);
    }

    final async = ref.watch(appointmentsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (res) {
        if (res.past.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: const Text('Aún no hay actividad',
                style: TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          );
        }
        final items = res.past.take(5).map((apt) => _ActivityItem(
              title: '${apt.service} · ${_pastStatusLabel(apt.status)}',
              subtitle: apt.staffName ?? 'Clínica',
              date: _friendlyDate(apt.date),
              icon: _pastIcon(apt.status),
              iconColor: _pastIconColor(apt.status),
            )).toList();
        return _activityList(items);
      },
    );
  }

  Widget _activityList(List<_ActivityItem> items) => Column(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: KiltoColors.navy,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: KiltoColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: KiltoColors.greyText,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );

  String _pastStatusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      case 'no_show':
        return 'No asistió';
      default:
        return status;
    }
  }

  IconData _pastIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'cancelled':
      case 'no_show':
        return Icons.highlight_off;
      default:
        return Icons.event;
    }
  }

  Color _pastIconColor(String status) {
    switch (status) {
      case 'completed':
        return KiltoColors.green;
      case 'cancelled':
      case 'no_show':
        return KiltoColors.red;
      default:
        return KiltoColors.blue;
    }
  }

  String _friendlyDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
  }
}

class _QuickAction {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  _QuickAction({required this.emoji, required this.label, required this.onTap});
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String date;
  final IconData icon;
  final Color iconColor;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
  });
}
