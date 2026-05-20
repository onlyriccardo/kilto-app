import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/widgets/kilto_card.dart';
import '../../../../core/widgets/kilto_date_badge.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_hero_card.dart';
import '../../../../core/widgets/kilto_quick_action_tile.dart';
import '../../../../core/widgets/kilto_section_header.dart';
import '../../../../core/widgets/kilto_text.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final membership = ref.watch(tenantSessionProvider).membership;
    final firstName = kDemoMode
        ? DemoData.user['first_name'] as String
        : (auth.userName?.split(' ').first ?? 'Usuario');
    final tenantName = membership?.tenantName ??
        (kDemoMode
            ? DemoData.tenant['name'] as String
            : (auth.tenantName ?? 'Clínica'));

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(appointmentsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ClinicHeader(
                  tenantName: tenantName,
                  onNotifications: () =>
                      context.push('/client/notifications'),
                ),
                const SizedBox(height: 24),
                KiltoText.label('Hola, $firstName 👋'),
                const SizedBox(height: 2),
                KiltoText.h2('Tus próximas citas'),
                const SizedBox(height: 16),
                _UpcomingSection(),
                const SizedBox(height: 28),
                const KiltoSectionHeader('Acciones rápidas'),
                _QuickActionsGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClinicHeader extends StatelessWidget {
  final String tenantName;
  final VoidCallback onNotifications;

  const _ClinicHeader({
    required this.tenantName,
    required this.onNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;
    final fg = accent.computeLuminance() > 0.55 ? Colors.black : Colors.white;
    final initial = tenantName.isNotEmpty ? tenantName[0].toUpperCase() : '?';

    return KiltoCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.14), accent),
                ],
              ),
              borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.32),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: KiltoText.strong(tenantName, size: 13),
          ),
          Material(
            color: KiltoColors.zinc100,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onNotifications,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.notifications_outlined,
                    size: 16, color: KiltoColors.zinc700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kDemoMode) {
      final upcoming = DemoData.upcomingAppointments
          .map((m) => _DisplayAppt(
                id: m['id'] as int? ?? 0,
                service: m['service'] as String,
                date: DateTime.tryParse(m['date'] as String) ?? DateTime.now(),
                time: m['time'] as String,
                staffName: m['doctor'] as String?,
              ))
          .toList();
      return _UpcomingList(items: upcoming);
    }

    final async = ref.watch(appointmentsProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const _EmptyUpcoming(),
      data: (res) {
        if (res.upcoming.isEmpty) return const _EmptyUpcoming();
        final items = res.upcoming
            .map((apt) => _DisplayAppt(
                  id: apt.id,
                  service: apt.service,
                  date: DateTime.tryParse(apt.date) ?? DateTime.now(),
                  time: apt.time,
                  staffName: apt.staffName,
                ))
            .toList();
        return _UpcomingList(items: items);
      },
    );
  }
}

class _UpcomingList extends StatelessWidget {
  final List<_DisplayAppt> items;
  const _UpcomingList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyUpcoming();

    final first = items.first;
    final rest = items.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroAppointment(appt: first),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final a in rest) ...[
            _UpcomingRow(appt: a),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _HeroAppointment extends StatelessWidget {
  final _DisplayAppt appt;
  const _HeroAppointment({required this.appt});

  @override
  Widget build(BuildContext context) {
    final daysAway = appt.date.difference(DateTime.now()).inDays;
    final eyebrow = daysAway <= 0
        ? 'PRÓXIMA CITA · HOY'
        : daysAway == 1
            ? 'PRÓXIMA CITA · MAÑANA'
            : 'PRÓXIMA CITA · EN $daysAway DÍAS';

    return KiltoHeroCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 1.1,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _dateLong(appt.date),
            style: const TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              height: 1.05,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${appt.time} · ${appt.service}',
            style: TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.95),
            ),
          ),
          if (appt.staffName != null && appt.staffName!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: const Icon(Icons.person_outline,
                      size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    appt.staffName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: KiltoFonts.familyBody,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static const _esDays = [
    'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo',
  ];
  static const _esMonths = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  String _dateLong(DateTime d) {
    final day = _esDays[(d.weekday - 1).clamp(0, 6)];
    final month = _esMonths[(d.month - 1).clamp(0, 11)];
    return '${_cap(day)} ${d.day} $month';
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _UpcomingRow extends StatelessWidget {
  final _DisplayAppt appt;
  const _UpcomingRow({required this.appt});

  @override
  Widget build(BuildContext context) {
    return KiltoCard(
      onTap: () {},
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          KiltoDateBadge(date: appt.date),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KiltoText.strong(appt.service, size: 13),
                const SizedBox(height: 2),
                KiltoText.label(
                  '${appt.time}${appt.staffName != null && appt.staffName!.isNotEmpty ? ' · ${appt.staffName}' : ''}',
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: KiltoColors.zinc400),
        ],
      ),
    );
  }
}

class _EmptyUpcoming extends StatelessWidget {
  const _EmptyUpcoming();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: KiltoEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No tienes citas próximas',
        subtitle:
            'Cuando tu clínica programe una visita, aparecerá aquí y te avisaremos.',
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.05,
      children: [
        KiltoQuickActionTile(
          emoji: '📅',
          label: 'Nueva cita',
          onTap: () => context.push('/client/book-appointment'),
        ),
        KiltoQuickActionTile(
          emoji: '📋',
          label: 'Mi historial',
          onTap: () => context.go('/client/appointments'),
        ),
        KiltoQuickActionTile(
          emoji: '📁',
          label: 'Documentos',
          onTap: () => context.go('/client/documents'),
        ),
      ],
    );
  }
}

class _DisplayAppt {
  final int id;
  final String service;
  final DateTime date;
  final String time;
  final String? staffName;
  _DisplayAppt({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    this.staffName,
  });
}
