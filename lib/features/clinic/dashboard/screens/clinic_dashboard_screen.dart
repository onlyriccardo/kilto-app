import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_data.dart';
import '../../subscreens/patient_detail_screen.dart';
import '../../subscreens/clinic_notifications_screen.dart';

class ClinicDashboardScreen extends StatelessWidget {
  const ClinicDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinicUser = DemoData.clinicUser;
    final initials = clinicUser['initials'] as String;
    final name = clinicUser['name'] as String;
    final firstName = name.split(' ').length > 1 ? name.split(' ')[0] + ' ' + name.split(' ')[1] : name;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context, initials, firstName),
              const SizedBox(height: 24),
              _buildKpiGrid(),
              const SizedBox(height: 24),
              _buildInProgressCard(context),
              const SizedBox(height: 24),
              _buildUpcomingSection(context),
              const SizedBox(height: 24),
              _buildRecentActivitySection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String initials, String name) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: KiltoColors.navy,
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
                '$name \u{1F44B}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
              Text(
                DemoData.tenant['name'] as String,
                style: const TextStyle(
                  fontSize: 13,
                  color: KiltoColors.greyText,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ClinicNotificationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: KiltoColors.navy,
                size: 26,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: KiltoColors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid() {
    final kpis = [
      _KpiData(emoji: '\u{1F4C5}', title: 'Citas hoy', value: '8', sub: '3 completadas', accent: KiltoColors.teal),
      _KpiData(emoji: '\u{1F4B0}', title: 'Ingresos (Abr)', value: '18.4k Bs', sub: '+12% vs Mar', accent: KiltoColors.green),
      _KpiData(emoji: '\u{1F465}', title: 'Pacientes activos', value: '156', sub: '+7 este mes', accent: KiltoColors.blue),
      _KpiData(emoji: '\u{1F4AC}', title: 'Msg sin leer', value: '3', sub: '2 urgentes', accent: KiltoColors.yellow),
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
                        fontSize: 12,
                        color: KiltoColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                kpi.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: kpi.accent,
                ),
              ),
              Text(
                kpi.sub,
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
  }

  Widget _buildInProgressCard(BuildContext context) {
    final inProgress = DemoData.todayAppointments
        .where((a) => a['status'] == 'in-progress')
        .toList();

    if (inProgress.isEmpty) return const SizedBox.shrink();

    final appt = inProgress.first;
    final patientIdx = appt['patientIdx'] as int;
    final patient = DemoData.patients[patientIdx];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(patient: patient),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [KiltoColors.navy, KiltoColors.navyLight],
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
                    color: KiltoColors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulsingDot(),
                      const SizedBox(width: 6),
                      const Text(
                        'En curso ahora',
                        style: TextStyle(
                          color: KiltoColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: KiltoColors.teal,
                  child: Text(
                    patient['initials'] as String,
                    style: const TextStyle(
                      color: KiltoColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient['name'] as String,
                        style: const TextStyle(
                          color: KiltoColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appt['service'] as String,
                        style: TextStyle(
                          color: KiltoColors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
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
                  '${appt['time']} - ${appt['end']}',
                  style: TextStyle(
                    color: KiltoColors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.room_outlined, color: KiltoColors.white.withOpacity(0.6), size: 14),
                const SizedBox(width: 4),
                Text(
                  appt['room'] as String,
                  style: TextStyle(
                    color: KiltoColors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    final upcoming = DemoData.todayAppointments
        .where((a) => a['status'] == 'confirmed' || a['status'] == 'pending')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pr\u00f3ximas hoy',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to agenda tab — handled by parent tab controller
              },
              child: const Text(
                'Ver agenda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...upcoming.map((appt) {
          final patientIdx = appt['patientIdx'] as int;
          final patient = DemoData.patients[patientIdx];
          final status = appt['status'] as String;
          final isConfirmed = status == 'confirmed';
          final barColor = isConfirmed ? KiltoColors.teal : KiltoColors.yellow;
          final statusLabel = isConfirmed ? 'Confirmada' : 'Pendiente';
          final statusBg = isConfirmed ? KiltoColors.tealLight : KiltoColors.yellowLight;
          final statusFg = isConfirmed ? KiltoColors.tealDark : KiltoColors.yellow;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDetailScreen(patient: patient),
                ),
              );
            },
            child: Container(
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
                        appt['time'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: KiltoColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: KiltoColors.navy,
                      child: Text(
                        patient['initials'] as String,
                        style: const TextStyle(
                          color: KiltoColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
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
                              patient['name'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: KiltoColors.navy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appt['service'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: KiltoColors.greyText,
                              ),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad reciente',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: KiltoColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: KiltoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KiltoColors.greyMid),
          ),
          child: Column(
            children: DemoData.recentActivity.asMap().entries.map((entry) {
              final idx = entry.key;
              final activity = entry.value;
              final isLast = idx == DemoData.recentActivity.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          activity['icon'] as String,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activity['text'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              color: KiltoColors.navy,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          activity['time'] as String,
                          style: const TextStyle(
                            fontSize: 11,
                            color: KiltoColors.greyText,
                          ),
                        ),
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

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: KiltoColors.green,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
