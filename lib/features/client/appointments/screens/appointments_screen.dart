import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/widgets/kilto_card.dart';
import '../../../../core/widgets/kilto_date_badge.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_text.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KiltoText.label('Mis citas'),
                  const SizedBox(height: 2),
                  KiltoText.h1('Historial'),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: accent,
              unselectedLabelColor: KiltoColors.zinc500,
              indicatorColor: accent,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: KiltoColors.border,
              labelStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: -0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Próximas'),
                Tab(text: 'Pasadas'),
              ],
            ),
            Expanded(
              child: kDemoMode ? _buildDemoBody() : _buildRealBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/client/book-appointment'),
        backgroundColor: accent,
        foregroundColor:
            accent.computeLuminance() > 0.55 ? Colors.black : Colors.white,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text(
          'Nueva cita',
          style: TextStyle(
            fontFamily: KiltoFonts.familyHeading,
            fontWeight: FontWeight.w800,
            fontSize: 13,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  // ── Demo path (kDemoMode=true) ────────────────────────────────────
  Widget _buildDemoBody() {
    final upcoming = DemoData.upcomingAppointments
        .map((apt) => _Item.fromMap(apt))
        .toList();
    final past = DemoData.pastAppointments
        .map((apt) => _Item.fromMap(apt))
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _list(upcoming, isUpcoming: true),
        _list(past, isUpcoming: false),
      ],
    );
  }

  // ── Real API path ─────────────────────────────────────────────────
  Widget _buildRealBody() {
    final asyncData = ref.watch(appointmentsProvider);
    return asyncData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorState(e.toString()),
      data: (res) => TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(appointmentsProvider),
            child: _list(
              res.upcoming.map(_Item.fromAppointment).toList(),
              isUpcoming: true,
              actions: (item) => _UpcomingActions(
                onReschedule: () => _onReschedule(item.appointment!),
                onCancel: () => _onCancel(item.appointment!),
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(appointmentsProvider),
            child: _list(
              res.past.map(_Item.fromAppointment).toList(),
              isUpcoming: false,
              actions: (item) => _PastActions(
                onDetails: () => _showDetails(item.appointment!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    List<_Item> items, {
    required bool isUpcoming,
    Widget Function(_Item)? actions,
  }) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 80),
        children: [
          KiltoEmptyState(
            icon: isUpcoming
                ? Icons.calendar_today_outlined
                : Icons.history_rounded,
            title: isUpcoming
                ? 'No tienes citas próximas'
                : 'Sin historial de citas',
            subtitle: isUpcoming
                ? 'Agenda tu primera cita con el botón de abajo.'
                : 'Aquí aparecerán tus citas pasadas.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 96),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final it = items[i];
        return _AppointmentCard(
          item: it,
          isUpcoming: isUpcoming,
          trailing: actions?.call(it),
        );
      },
    );
  }

  // ── Mutations ─────────────────────────────────────────────────────
  Future<void> _onCancel(Appointment apt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Text(
            '¿Seguro que quieres cancelar tu cita del ${_formatDateLabel(apt.date)} a las ${apt.time}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar',
                style: TextStyle(color: KiltoColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appointmentsServiceProvider).cancel(apt.id);
      ref.invalidate(appointmentsProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Cita cancelada')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _onReschedule(Appointment apt) async {
    final initial = DateTime.tryParse(apt.date) ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now())
          ? initial
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _parseTime(apt.time),
    );
    if (time == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appointmentsServiceProvider).reschedule(
            id: apt.id,
            date:
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            time:
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          );
      ref.invalidate(appointmentsProvider);
      messenger.showSnackBar(const SnackBar(content: Text('Cita reagendada')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 9,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
  }

  void _showDetails(Appointment apt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KiltoRadii.xlarge)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: KiltoColors.zinc300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            KiltoText.h3(apt.service),
            const SizedBox(height: 14),
            _detailRow('Fecha', _formatDateLabel(apt.date)),
            _detailRow('Hora', apt.time),
            _detailRow('Duración', '${apt.duration} min'),
            if (apt.staffName != null && apt.staffName!.isNotEmpty)
              _detailRow('Profesional', apt.staffName!),
            _detailRow('Estado', _statusLabel(apt.status)),
            if (apt.notes != null && apt.notes!.isNotEmpty)
              _detailRow('Notas', apt.notes!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: KiltoText.label(label)),
            Expanded(child: KiltoText.body(value, color: KiltoColors.zinc950)),
          ],
        ),
      );

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'Completada';
      case 'cancelled':
        return 'Cancelada';
      case 'no_show':
        return 'No asistió';
      case 'scheduled':
        return 'Confirmada';
      default:
        return status;
    }
  }

  /// Turns `2026-04-23` into `Jue, 23 Abr 2026`.
  String _formatDateLabel(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildErrorState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: 40, color: KiltoColors.zinc400),
              const SizedBox(height: 12),
              KiltoText.h3('No se pudieron cargar las citas'),
              const SizedBox(height: 6),
              KiltoText.body(msg,
                  align: TextAlign.center, color: KiltoColors.zinc500),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => ref.invalidate(appointmentsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
}

/// Internal view-model that both real-API and demo paths feed into.
class _Item {
  final DateTime date;
  final String dateLabel;
  final String time;
  final String service;
  final String? staffName;
  final String status;
  final Appointment? appointment;

  _Item({
    required this.date,
    required this.dateLabel,
    required this.time,
    required this.service,
    required this.staffName,
    required this.status,
    this.appointment,
  });

  factory _Item.fromAppointment(Appointment apt) {
    final d = DateTime.tryParse(apt.date) ?? DateTime.now();
    return _Item(
      date: d,
      dateLabel: _formatLabel(d),
      time: apt.time,
      service: apt.service,
      staffName: apt.staffName,
      status: apt.status,
      appointment: apt,
    );
  }

  factory _Item.fromMap(Map<String, dynamic> m) {
    final d = DateTime.tryParse(m['date'] as String? ?? '') ?? DateTime.now();
    return _Item(
      date: d,
      dateLabel: _formatLabel(d),
      time: m['time'] as String? ?? '',
      service: m['service'] as String? ?? '',
      staffName: m['doctor'] as String?,
      status: 'scheduled',
    );
  }

  static String _formatLabel(DateTime d) {
    const weekdays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return '${weekdays[d.weekday - 1]}, ${d.day}';
  }
}

class _AppointmentCard extends StatelessWidget {
  final _Item item;
  final bool isUpcoming;
  final Widget? trailing;
  const _AppointmentCard({
    required this.item,
    required this.isUpcoming,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return KiltoCard(
      onTap: () {},
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KiltoDateBadge(date: item.date),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: KiltoText.strong(item.service, size: 14),
                        ),
                        const SizedBox(width: 8),
                        _StatusPill(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    KiltoText.label(
                      '${item.time}${item.staffName != null && item.staffName!.isNotEmpty ? ' · ${item.staffName}' : ''}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, fg, bg) = switch (status) {
      'completed' => ('Completada', KiltoColors.info, KiltoColors.infoLight),
      'cancelled' || 'no_show' => (
          status == 'no_show' ? 'No asistió' : 'Cancelada',
          KiltoColors.error,
          KiltoColors.errorLight,
        ),
      _ => ('Confirmada', KiltoColors.success, KiltoColors.successLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}

class _UpcomingActions extends StatelessWidget {
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  const _UpcomingActions({required this.onReschedule, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReschedule,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            child: const Text('Reagendar'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: KiltoColors.error,
              side: const BorderSide(color: KiltoColors.errorLight, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 10),
              textStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}

class _PastActions extends StatelessWidget {
  final VoidCallback onDetails;
  const _PastActions({required this.onDetails});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onDetails,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          textStyle: const TextStyle(
            fontFamily: KiltoFonts.familyHeading,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        child: const Text('Ver detalles'),
      ),
    );
  }
}
