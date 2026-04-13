import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUpcomingTab(),
          _buildPastTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/client/book-appointment'),
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

  Widget _buildUpcomingTab() {
    final upcomingAppointments = kDemoMode
        ? DemoData.upcomingAppointments.map((apt) => _AppointmentData(
              date: apt['date'] as String,
              time: apt['time'] as String,
              service: apt['service'] as String,
              doctor: apt['doctor'] as String,
              status: apt['status'] == 'confirmed' ? 'Confirmada' : 'Pendiente',
              statusColor: apt['status'] == 'confirmed' ? KiltoColors.green : KiltoColors.yellow,
              statusBg: apt['status'] == 'confirmed' ? KiltoColors.greenLight : KiltoColors.yellowLight,
            )).toList()
        : [
            _AppointmentData(
              date: 'Lun, 15 Abr 2026',
              time: '10:00 AM',
              service: 'Limpieza dental',
              doctor: 'Dr. María López',
              status: 'Confirmada',
              statusColor: KiltoColors.green,
              statusBg: KiltoColors.greenLight,
            ),
            _AppointmentData(
              date: 'Mié, 23 Abr 2026',
              time: '3:30 PM',
              service: 'Control de ortodoncia',
              doctor: 'Dr. Carlos Mendoza',
              status: 'Pendiente',
              statusColor: KiltoColors.yellow,
              statusBg: KiltoColors.yellowLight,
            ),
          ];

    if (upcomingAppointments.isEmpty) {
      return _buildEmptyState(
        'No tienes citas próximas',
        'Agenda tu primera cita con el botón de abajo',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: upcomingAppointments.length,
      itemBuilder: (context, index) {
        final apt = upcomingAppointments[index];
        return _buildAppointmentCard(apt, isUpcoming: true);
      },
    );
  }

  Widget _buildPastTab() {
    final pastAppointments = kDemoMode
        ? DemoData.pastAppointments.map((apt) => _AppointmentData(
              date: apt['date'] as String,
              time: apt['time'] as String,
              service: apt['service'] as String,
              doctor: apt['doctor'] as String,
              status: 'Completada',
              statusColor: KiltoColors.blue,
              statusBg: KiltoColors.blueLight,
            )).toList()
        : [
            _AppointmentData(
              date: 'Jue, 28 Mar 2026',
              time: '11:00 AM',
              service: 'Limpieza dental',
              doctor: 'Dr. María López',
              status: 'Completada',
              statusColor: KiltoColors.blue,
              statusBg: KiltoColors.blueLight,
            ),
            _AppointmentData(
              date: 'Lun, 10 Mar 2026',
              time: '9:00 AM',
              service: 'Extracción molar',
              doctor: 'Dr. Ana Rojas',
              status: 'Completada',
              statusColor: KiltoColors.blue,
              statusBg: KiltoColors.blueLight,
            ),
          ];

    if (pastAppointments.isEmpty) {
      return _buildEmptyState(
        'Sin historial de citas',
        'Aquí aparecerán tus citas pasadas',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pastAppointments.length,
      itemBuilder: (context, index) {
        final apt = pastAppointments[index];
        return _buildAppointmentCard(apt, isUpcoming: false);
      },
    );
  }

  Widget _buildAppointmentCard(_AppointmentData apt,
      {required bool isUpcoming}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                apt.date,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: apt.statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  apt.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: apt.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time, size: 15, color: KiltoColors.greyText),
              const SizedBox(width: 6),
              Text(
                apt.time,
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                ),
              ),
            ],
          ),
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
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: KiltoColors.teal.withOpacity(0.15),
                child: Text(
                  apt.doctor.split(' ').last[0],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                apt.doctor,
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isUpcoming)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Reschedule flow
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KiltoColors.navy,
                      side: const BorderSide(color: KiltoColors.greyMid),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Reagendar',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Cancel flow
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KiltoColors.red,
                      side: const BorderSide(color: KiltoColors.redLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Cancelar',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // View details
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: KiltoColors.navy,
                  side: const BorderSide(color: KiltoColors.greyMid),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text(
                  'Ver detalles',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
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
      ),
    );
  }
}

class _AppointmentData {
  final String date;
  final String time;
  final String service;
  final String doctor;
  final String status;
  final Color statusColor;
  final Color statusBg;

  _AppointmentData({
    required this.date,
    required this.time,
    required this.service,
    required this.doctor,
    required this.status,
    required this.statusColor,
    required this.statusBg,
  });
}
