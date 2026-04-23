import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/clinic_providers.dart';
import '../../subscreens/patient_detail_screen.dart';

/// Staff agenda — list of appointments for a given day, fetched from
/// /v1/clinic/appointments?date=YYYY-MM-DD. Displays a rolling 7-day window
/// starting from today. Tapping a day refetches; tapping an appointment
/// opens the patient detail.
class ClinicAgendaScreen extends ConsumerStatefulWidget {
  const ClinicAgendaScreen({super.key});

  @override
  ConsumerState<ClinicAgendaScreen> createState() => _ClinicAgendaScreenState();
}

class _ClinicAgendaScreenState extends ConsumerState<ClinicAgendaScreen> {
  int _selectedOffset = 0; // days from today

  static const _weekdayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _monthLabels = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final selectedDate = today.add(Duration(days: _selectedOffset));
    final async = ref.watch(clinicAgendaProvider(_fmtDate(selectedDate)));

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(selectedDate),
            const SizedBox(height: 16),
            _buildDaySelector(today),
            const SizedBox(height: 16),
            Expanded(
              child: async.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: KiltoColors.red, size: 36),
                        const SizedBox(height: 8),
                        Text('No se pudo cargar la agenda\n$err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: KiltoColors.greyText)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref
                              .invalidate(clinicAgendaProvider(_fmtDate(selectedDate))),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (d) {
                  final appointments =
                      ((d['appointments'] as List?) ?? [])
                          .map((e) => (e as Map).cast<String, dynamic>())
                          .toList();
                  return RefreshIndicator(
                    onRefresh: () async => ref
                        .invalidate(clinicAgendaProvider(_fmtDate(selectedDate))),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '${appointments.length} citas programadas',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: KiltoColors.greyText,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                        if (appointments.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'No hay citas programadas para este día.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: KiltoColors.greyText),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList.builder(
                              itemCount: appointments.length,
                              itemBuilder: (context, i) =>
                                  _buildTimelineItem(context, appointments[i]),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAppointmentSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTitle(DateTime d) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agenda',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, color: KiltoColors.navy),
            ),
            const SizedBox(height: 2),
            Text(
              '${_monthLabels[d.month - 1]} ${d.year}',
              style: const TextStyle(fontSize: 14, color: KiltoColors.greyText),
            ),
          ],
        ),
      );

  Widget _buildDaySelector(DateTime today) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final dayDate = today.add(Duration(days: index));
          final isSelected = _selectedOffset == index;
          final isToday = index == 0;
          final accent = Theme.of(context).colorScheme.primary;

          return GestureDetector(
            onTap: () => setState(() => _selectedOffset = index),
            child: Container(
              width: 56,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? accent : KiltoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? accent : KiltoColors.greyMid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabels[(dayDate.weekday - 1) % 7],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? KiltoColors.white : KiltoColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dayDate.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? KiltoColors.white : KiltoColors.navy,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isSelected ? KiltoColors.white : accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> appt) {
    final status = appt['status'] as String? ?? 'confirmed';

    Color barColor;
    String statusLabel;
    Color statusBg;
    Color statusFg;

    switch (status) {
      case 'completed':
        barColor = KiltoColors.green;
        statusLabel = 'Completada';
        statusBg = KiltoColors.greenLight;
        statusFg = KiltoColors.green;
        break;
      case 'in_progress':
        barColor = KiltoColors.blue;
        statusLabel = 'En curso';
        statusBg = KiltoColors.blueLight;
        statusFg = KiltoColors.blue;
        break;
      case 'cancelled':
      case 'no_show':
        barColor = KiltoColors.red;
        statusLabel = status == 'cancelled' ? 'Cancelada' : 'No vino';
        statusBg = KiltoColors.redLight;
        statusFg = KiltoColors.red;
        break;
      case 'confirmed':
      default:
        final accent = Theme.of(context).colorScheme.primary;
        barColor = accent;
        statusLabel = 'Confirmada';
        statusBg = Color.alphaBlend(accent.withOpacity(0.12), Colors.white);
        statusFg = accent;
        break;
    }

    return GestureDetector(
      onTap: () {
        final contactId = appt['contact_id'] as int?;
        if (contactId == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patientId: contactId),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appt['time'] as String? ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  Text(
                    appt['end_time'] as String? ?? '',
                    style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      appt['patient_name'] as String? ?? '',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: KiltoColors.navy),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: statusFg),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appt['service'] as String? ?? '',
                                style: const TextStyle(
                                    fontSize: 12, color: KiltoColors.greyText),
                              ),
                              if (appt['staff_name'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 12, color: KiltoColors.greyText),
                                    const SizedBox(width: 4),
                                    Text(
                                      appt['staff_name'] as String,
                                      style: const TextStyle(
                                          fontSize: 11, color: KiltoColors.greyText),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewAppointmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nueva Cita',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy)),
            const SizedBox(height: 12),
            const Text(
              'Abre el detalle de un paciente y toca "Agendar cita" para registrar una nueva visita.',
              style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
