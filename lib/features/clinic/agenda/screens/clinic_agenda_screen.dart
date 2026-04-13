import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_data.dart';
import '../../subscreens/patient_detail_screen.dart';

class ClinicAgendaScreen extends StatefulWidget {
  const ClinicAgendaScreen({super.key});

  @override
  State<ClinicAgendaScreen> createState() => _ClinicAgendaScreenState();
}

class _ClinicAgendaScreenState extends State<ClinicAgendaScreen> {
  int _selectedDayIndex = 0;

  final List<Map<String, dynamic>> _days = const [
    {'label': 'Lun', 'day': '14', 'isToday': true},
    {'label': 'Mar', 'day': '15', 'isToday': false},
    {'label': 'Mi\u00e9', 'day': '16', 'isToday': false},
    {'label': 'Jue', 'day': '17', 'isToday': false},
    {'label': 'Vie', 'day': '18', 'isToday': false},
  ];

  @override
  Widget build(BuildContext context) {
    final appointments = DemoData.todayAppointments;
    final count = appointments.length;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Agenda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Abril 2026',
                    style: TextStyle(
                      fontSize: 14,
                      color: KiltoColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Day selector
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _days.length,
                itemBuilder: (context, index) {
                  final day = _days[index];
                  final isSelected = _selectedDayIndex == index;
                  final isToday = day['isToday'] as bool;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? KiltoColors.teal : KiltoColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? KiltoColors.white : KiltoColors.greyText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            day['day'] as String,
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
                                color: isSelected ? KiltoColors.white : KiltoColors.teal,
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
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '$count citas programadas',
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Timeline list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return _buildTimelineItem(context, appt);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewAppointmentSheet(context),
        backgroundColor: KiltoColors.teal,
        foregroundColor: KiltoColors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nueva cita',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showNewAppointmentSheet(BuildContext context) {
    String? selectedService;
    String? selectedPatient;
    String? selectedTime;
    final serviceNames = DemoData.services.map((s) => s['name'] as String).toList();
    final patientNames = DemoData.patients.map((p) => p['name'] as String).toList();
    final timeSlots = DemoData.availableTimeSlots;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Nueva Cita', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(labelText: 'Servicio', border: OutlineInputBorder()),
                items: serviceNames.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setSheetState(() => selectedService = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPatient,
                decoration: const InputDecoration(labelText: 'Paciente', border: OutlineInputBorder()),
                items: patientNames.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (v) => setSheetState(() => selectedPatient = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                readOnly: true,
                initialValue: 'Hoy - Abril 14, 2026',
                decoration: const InputDecoration(labelText: 'Fecha', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTime,
                decoration: const InputDecoration(labelText: 'Hora', border: OutlineInputBorder()),
                items: timeSlots.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => selectedTime = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita agendada exitosamente'), backgroundColor: Color(0xFF2EC4B6)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> appt) {
    final status = appt['status'] as String;
    final patientIdx = appt['patientIdx'] as int;
    final patient = DemoData.patients[patientIdx];

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
      case 'in-progress':
        barColor = KiltoColors.blue;
        statusLabel = 'En curso';
        statusBg = KiltoColors.blueLight;
        statusFg = KiltoColors.blue;
        break;
      case 'confirmed':
        barColor = KiltoColors.teal;
        statusLabel = 'Confirmada';
        statusBg = KiltoColors.tealLight;
        statusFg = KiltoColors.tealDark;
        break;
      case 'pending':
      default:
        barColor = KiltoColors.yellow;
        statusLabel = 'Pendiente';
        statusBg = KiltoColors.yellowLight;
        statusFg = KiltoColors.yellow;
        break;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    appt['time'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  Text(
                    appt['end'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: KiltoColors.greyText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Card
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
                                      patient['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: KiltoColors.navy,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: statusBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusFg,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appt['service'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KiltoColors.greyText,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.room_outlined, size: 13, color: KiltoColors.greyText),
                                  const SizedBox(width: 4),
                                  Text(
                                    appt['room'] as String,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: KiltoColors.greyText,
                                    ),
                                  ),
                                ],
                              ),
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
}
