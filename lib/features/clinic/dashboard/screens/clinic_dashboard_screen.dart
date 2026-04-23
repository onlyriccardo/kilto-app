import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/clinic_providers.dart';
import '../../subscreens/clinic_notifications_screen.dart';

/// Clinic staff dashboard. Reads from /v1/clinic/dashboard and renders:
///   • Header (staff avatar + name + clinic name)
///   • KPI grid (citas hoy / ingresos / pacientes / msg)
///   • En-curso appointment card (if any)
///   • Upcoming-today list
///   • Recent activity feed (currently empty until activity log ships)
class ClinicDashboardScreen extends ConsumerWidget {
  const ClinicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicDashboardProvider);

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => _ErrorState(
            error: err,
            onRetry: () => ref.invalidate(clinicDashboardProvider),
          ),
          data: (d) => RefreshIndicator(
            onRefresh: () async => ref.invalidate(clinicDashboardProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(context, d),
                  const SizedBox(height: 24),
                  _buildKpiGrid(context, d),
                  const SizedBox(height: 24),
                  if (d['in_progress'] != null) ...[
                    _buildInProgressCard(context, d['in_progress'] as Map<String, dynamic>),
                    const SizedBox(height: 24),
                  ],
                  _buildUpcomingSection(context, d),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(d),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> d) {
    final staff = (d['staff'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = staff['name'] as String? ?? 'Staff';
    final initials = staff['initials'] as String? ?? '??';
    final tenantName =
        (d['tenant_name'] as String?) ?? 'Clínica'; // will be filled once /settings integrated
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: accent,
          child: Text(
            initials,
            style: TextStyle(color: onAccent, fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name \u{1F44B}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700, color: KiltoColors.navy),
              ),
              Text(
                tenantName,
                style: const TextStyle(fontSize: 13, color: KiltoColors.greyText),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ClinicNotificationsScreen()));
          },
          icon: const Icon(Icons.notifications_outlined, color: KiltoColors.navy, size: 26),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, Map<String, dynamic> d) {
    final k = (d['kpis'] as Map?)?.cast<String, dynamic>() ?? {};
    final kpis = [
      _KpiData(
        emoji: '\u{1F4C5}',
        title: 'Citas hoy',
        value: '${k['appointments_today'] ?? 0}',
        sub: '${k['appointments_completed_today'] ?? 0} completadas',
        accent: Theme.of(context).colorScheme.primary,
      ),
      _KpiData(
        emoji: '\u{1F4B0}',
        title: 'Ingresos (mes)',
        value: '${k['revenue_month'] ?? 0} Bs',
        sub: (k['revenue_month_delta_pct'] != null && (k['revenue_month_delta_pct'] as num) != 0)
            ? '${k['revenue_month_delta_pct']}% vs mes ant.'
            : 'Sin datos',
        accent: KiltoColors.green,
      ),
      _KpiData(
        emoji: '\u{1F465}',
        title: 'Pacientes activos',
        value: '${k['active_patients'] ?? 0}',
        sub: '+${k['new_patients_month'] ?? 0} este mes',
        accent: KiltoColors.blue,
      ),
      _KpiData(
        emoji: '\u{1F4AC}',
        title: 'Msg sin leer',
        value: '${k['unread_messages'] ?? 0}',
        sub: '${k['urgent_messages'] ?? 0} urgentes',
        accent: KiltoColors.yellow,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: kpis.map((kpi) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KiltoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KiltoColors.greyMid),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(kpi.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      kpi.title,
                      style: const TextStyle(
                          fontSize: 12, color: KiltoColors.greyText, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              Text(
                kpi.value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: kpi.accent),
              ),
              Text(kpi.sub,
                  style: const TextStyle(fontSize: 11, color: KiltoColors.greyText)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInProgressCard(BuildContext context, Map<String, dynamic> appt) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent,
            Color.alphaBlend(accent.withOpacity(0.85), Colors.black),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: KiltoColors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(),
                SizedBox(width: 6),
                Text(
                  'En curso ahora',
                  style: TextStyle(
                      color: KiltoColors.green, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  appt['patient_initials'] as String? ?? '??',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appt['patient_name'] as String? ?? '',
                      style: const TextStyle(
                          color: KiltoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      appt['service'] as String? ?? '',
                      style: TextStyle(
                          color: KiltoColors.white.withOpacity(0.7), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, color: KiltoColors.white.withOpacity(0.6), size: 14),
              const SizedBox(width: 4),
              Text(
                '${appt['time']} - ${appt['end_time']}',
                style: TextStyle(color: KiltoColors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context, Map<String, dynamic> d) {
    final upcoming = ((d['upcoming_today'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pr\u00f3ximas hoy',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: KiltoColors.navy),
            ),
            Text(
              'Ver agenda',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (upcoming.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: const Text('No hay más citas programadas hoy.',
                style: TextStyle(color: KiltoColors.greyText)),
          )
        else
          ...upcoming.map((a) => _upcomingRow(context, a)),
      ],
    );
  }

  Widget _upcomingRow(BuildContext context, Map<String, dynamic> a) {
    final status = a['status'] as String? ?? 'confirmed';
    final accent = Theme.of(context).colorScheme.primary;
    final accentLight = Color.alphaBlend(accent.withOpacity(0.12), Colors.white);
    final isConfirmed = status == 'confirmed';
    final barColor = isConfirmed ? accent : KiltoColors.yellow;
    final statusLabel = isConfirmed ? 'Confirmada' : 'Pendiente';
    final statusBg = isConfirmed ? accentLight : KiltoColors.yellowLight;
    final statusFg = isConfirmed ? accent : KiltoColors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                a['time'] as String? ?? '',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: KiltoColors.navy),
              ),
            ),
            const SizedBox(width: 14),
            CircleAvatar(
              radius: 18,
              backgroundColor: accent,
              child: Text(
                a['patient_initials'] as String? ?? '??',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a['patient_name'] as String? ?? '',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: KiltoColors.navy),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a['service'] as String? ?? '',
                      style: const TextStyle(fontSize: 12, color: KiltoColors.greyText),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: statusFg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(Map<String, dynamic> d) {
    final activities = ((d['recent_activity'] as List?) ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad reciente',
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w700, color: KiltoColors.navy),
        ),
        const SizedBox(height: 12),
        if (activities.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: const Text('Aún no hay actividad registrada.',
                style: TextStyle(color: KiltoColors.greyText)),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Column(
              children: activities.asMap().entries.map((entry) {
                final idx = entry.key;
                final a = entry.value;
                final isLast = idx == activities.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Text(a['icon'] as String? ?? '•',
                              style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              a['text'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: KiltoColors.navy),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(a['time'] as String? ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: KiltoColors.greyText)),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 14, endIndent: 14),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _KpiData {
  final String emoji;
  final String title;
  final String value;
  final String sub;
  final Color accent;
  _KpiData({
    required this.emoji,
    required this.title,
    required this.value,
    required this.sub,
    required this.accent,
  });
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: KiltoColors.red),
              const SizedBox(height: 12),
              Text('Error cargando el dashboard\n$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: KiltoColors.greyText)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _animation,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: KiltoColors.green, shape: BoxShape.circle),
        ),
      );
}
