import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              _buildHeader(context, initials, firstName, tenantName),
              const SizedBox(height: 24),
              // Next appointment card
              _buildNextAppointmentCard(context),
              const SizedBox(height: 24),
              // Quick actions
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
              // Health tip
              _buildHealthTipCard(),
              const SizedBox(height: 24),
              // Recent activity
              const Text(
                'Actividad reciente',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentActivity(),
              const SizedBox(height: 24),
            ],
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
          backgroundColor: KiltoColors.teal,
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
        Stack(
          children: [
            IconButton(
              onPressed: () => context.go('/client/notifications'),
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

  Widget _buildNextAppointmentCard(BuildContext context) {
    final nextAppt = kDemoMode ? DemoData.upcomingAppointments[0] : null;
    final apptService = kDemoMode ? nextAppt!['service'] as String : 'Limpieza dental';
    final apptDate = kDemoMode ? nextAppt!['date'] as String : 'Lun 15 Abr, 2026';
    final apptTime = kDemoMode ? nextAppt!['time'] as String : '10:00 AM';
    final apptDoctor = kDemoMode ? nextAppt!['doctor'] as String : 'Dr. María López';

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
            apptService,
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
              Text(
                apptDate,
                style: TextStyle(
                  color: KiltoColors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: KiltoColors.teal, size: 15),
              const SizedBox(width: 6),
              Text(
                apptTime,
                style: TextStyle(
                  color: KiltoColors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, color: KiltoColors.teal, size: 15),
              const SizedBox(width: 6),
              Text(
                apptDoctor,
                style: TextStyle(
                  color: KiltoColors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Confirm appointment
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KiltoColors.teal,
                    foregroundColor: KiltoColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Confirmar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/client/appointments');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: KiltoColors.white,
                    side: BorderSide(color: KiltoColors.white.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Reagendar',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
            ],
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
        onTap: () => context.go('/client/book-appointment'),
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
        onTap: () => context.go('/client/chat'),
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
                Text(
                  action.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
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

  Widget _buildRecentActivity() {
    final activities = kDemoMode
        ? DemoData.pastAppointments.map((apt) => _ActivityItem(
              title: '${apt['service']} - ${apt['status'] == 'completed' ? 'Completada' : apt['status']}',
              subtitle: apt['doctor'] as String,
              date: apt['date'] as String,
              icon: Icons.check_circle_outline,
              iconColor: KiltoColors.green,
            )).toList()
        : [
            _ActivityItem(
              title: 'Limpieza dental completada',
              subtitle: 'Dr. María López',
              date: '28 Mar, 2026',
              icon: Icons.check_circle_outline,
              iconColor: KiltoColors.green,
            ),
            _ActivityItem(
              title: 'Receta emitida',
              subtitle: 'Enjuague bucal',
              date: '28 Mar, 2026',
              icon: Icons.description_outlined,
              iconColor: KiltoColors.blue,
            ),
            _ActivityItem(
              title: 'Cita confirmada',
              subtitle: 'Control mensual',
              date: '20 Mar, 2026',
              icon: Icons.event_available,
              iconColor: KiltoColors.teal,
            ),
          ];

    return Column(
      children: activities.map((item) {
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
