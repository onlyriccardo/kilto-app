import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
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
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Mis citas'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: KiltoColors.teal,
          unselectedLabelColor: KiltoColors.greyText,
          indicatorColor: KiltoColors.teal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Pasadas'),
          ],
        ),
      ),
      body: kDemoMode ? _buildDemoBody() : _buildRealBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/client/book-appointment'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: KiltoColors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDemoBody() {
    final upcoming = DemoData.upcomingAppointments
        .map((apt) => _DemoTile(
              date: apt['date'] as String,
              time: apt['time'] as String,
              service: apt['service'] as String,
              doctor: apt['doctor'] as String,
            ))
        .toList();
    final past = DemoData.pastAppointments
        .map((apt) => _DemoTile(
              date: apt['date'] as String,
              time: apt['time'] as String,
              service: apt['service'] as String,
              doctor: apt['doctor'] as String,
            ))
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _listOrEmpty(
          upcoming,
          empty: _buildEmptyState(
            'No tienes citas próximas',
            'Agenda tu primera cita con el botón de abajo',
          ),
          builder: (t) => _buildDemoCard(t, isUpcoming: true),
        ),
        _listOrEmpty(
          past,
          empty: _buildEmptyState(
            'Sin historial de citas',
            'Aquí aparecerán tus citas pasadas',
          ),
          builder: (t) => _buildDemoCard(t, isUpcoming: false),
        ),
      ],
    );
  }

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
            child: _listOrEmpty(
              res.upcoming,
              empty: _buildEmptyState(
                'No tienes citas próximas',
                'Agenda tu primera cita con el botón de abajo',
              ),
              builder: (a) => _buildRealCard(a, isUpcoming: true),
            ),
          ),
          RefreshIndicator(
            onRefresh: () async => ref.invalidate(appointmentsProvider),
            child: _listOrEmpty(
              res.past,
              empty: _buildEmptyState(
                'Sin historial de citas',
                'Aquí aparecerán tus citas pasadas',
              ),
              builder: (a) => _buildRealCard(a, isUpcoming: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listOrEmpty<T>(
    List<T> items, {
    required Widget empty,
    required Widget Function(T) builder,
  }) {
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [SizedBox(height: 120), empty],
      );
    }
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => builder(items[i]),
    );
  }

  // ── Real API card ──────────────────────────────────────────────────
  Widget _buildRealCard(Appointment apt, {required bool isUpcoming}) {
    final statusBg = _statusBg(apt.status);
    final statusColor = _statusColor(apt.status);
    final statusLabel = _statusLabel(apt.status);
    final doctorName = apt.staffName ?? 'Profesional';
    final doctorInitial = doctorName.isNotEmpty ? doctorName[0] : '?';

    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(
            dateLabel: _formatDateLabel(apt.date),
            statusLabel: statusLabel,
            statusBg: statusBg,
            statusColor: statusColor,
          ),
          const SizedBox(height: 10),
          _iconRow(Icons.access_time, apt.time),
          const SizedBox(height: 6),
          Text(
            apt.service,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          _doctorRow(doctorInitial, doctorName),
          const SizedBox(height: 14),
          if (isUpcoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onReschedule(apt),
                    style: _neutralOutlined(),
                    child: const Text('Reagendar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _onCancel(apt),
                    style: _dangerOutlined(),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showDetails(apt),
                style: _neutralOutlined(),
                child: const Text('Ver detalles',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Demo card (legacy code path, unchanged behavior) ──────────────
  Widget _buildDemoCard(_DemoTile t, {required bool isUpcoming}) {
    return _cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerRow(
            dateLabel: t.date,
            statusLabel: isUpcoming ? 'Confirmada' : 'Completada',
            statusBg: isUpcoming ? KiltoColors.greenLight : KiltoColors.blueLight,
            statusColor: isUpcoming ? KiltoColors.green : KiltoColors.blue,
          ),
          const SizedBox(height: 10),
          _iconRow(Icons.access_time, t.time),
          const SizedBox(height: 6),
          Text(t.service,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.navy)),
          const SizedBox(height: 4),
          _doctorRow(t.doctor.split(' ').last[0], t.doctor),
          const SizedBox(height: 14),
          if (isUpcoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: _neutralOutlined(),
                    child: const Text('Reagendar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: _dangerOutlined(),
                    child: const Text('Cancelar',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: _neutralOutlined(),
                child: const Text('Ver detalles',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
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
                style: TextStyle(color: KiltoColors.red)),
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
      initialDate:
          initial.isAfter(DateTime.now()) ? initial : DateTime.now().add(const Duration(days: 1)),
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
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(apt.service,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy)),
            const SizedBox(height: 12),
            _detailRow('Fecha', _formatDateLabel(apt.date)),
            _detailRow('Hora', apt.time),
            _detailRow('Duración', '${apt.duration} min'),
            if (apt.staffName != null) _detailRow('Profesional', apt.staffName!),
            _detailRow('Estado', _statusLabel(apt.status)),
            if (apt.notes != null && apt.notes!.isNotEmpty)
              _detailRow('Notas', apt.notes!),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, color: KiltoColors.greyText)),
            ),
            Expanded(
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: KiltoColors.navy))),
          ],
        ),
      );

  // ── Shared visual helpers ─────────────────────────────────────────
  Widget _cardContainer({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: child,
      );

  Widget _headerRow({
    required String dateLabel,
    required String statusLabel,
    required Color statusBg,
    required Color statusColor,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(dateLabel,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusLabel,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor)),
          ),
        ],
      );

  Widget _iconRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 15, color: KiltoColors.greyText),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(
                  fontSize: 13, color: KiltoColors.greyText)),
        ],
      );

  Widget _doctorRow(String initial, String name) => Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: KiltoColors.teal.withOpacity(0.15),
            child: Text(initial,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.teal)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontSize: 13, color: KiltoColors.greyText)),
          ),
        ],
      );

  ButtonStyle _neutralOutlined() => OutlinedButton.styleFrom(
        foregroundColor: KiltoColors.navy,
        side: const BorderSide(color: KiltoColors.greyMid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      );

  ButtonStyle _dangerOutlined() => OutlinedButton.styleFrom(
        foregroundColor: KiltoColors.red,
        side: const BorderSide(color: KiltoColors.redLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      );

  Color _statusBg(String status) {
    switch (status) {
      case 'completed':
        return KiltoColors.blueLight;
      case 'cancelled':
      case 'no_show':
        return KiltoColors.redLight;
      case 'scheduled':
      default:
        return KiltoColors.greenLight;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return KiltoColors.blue;
      case 'cancelled':
      case 'no_show':
        return KiltoColors.red;
      case 'scheduled':
      default:
        return KiltoColors.green;
    }
  }

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

  /// Turns `2026-04-23` into `Jue, 23 Abr 2026` (best-effort).
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

  Widget _buildEmptyState(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: KiltoColors.greyText.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: KiltoColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: KiltoColors.greyText),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar las citas',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(appointmentsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
}

class _DemoTile {
  final String date;
  final String time;
  final String service;
  final String doctor;
  const _DemoTile({
    required this.date,
    required this.time,
    required this.service,
    required this.doctor,
  });
}
