import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/auth/auth_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _appointmentReminders = true;
  bool _promotions = false;
  bool _newDocuments = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final userName = kDemoMode ? DemoData.user['name'] as String : (auth.userName ?? 'Usuario');
    final userEmail = kDemoMode ? DemoData.user['email'] as String : (auth.userEmail ?? '');
    final userPhone = kDemoMode ? DemoData.user['phone'] as String : '+591 70012345';
    final initials = kDemoMode ? DemoData.user['initials'] as String : _getInitials(userName);
    final personal = kDemoMode ? DemoData.profile['personal'] as Map<String, dynamic> : null;
    final medical = kDemoMode ? DemoData.profile['medical'] as Map<String, dynamic> : null;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile card
            _buildProfileHeader(userName, userEmail, userPhone, initials),
            const SizedBox(height: 16),
            // Personal info
            _buildInfoCard(
              title: 'Información personal',
              icon: Icons.person_outline,
              items: kDemoMode
                  ? [
                      _InfoRow(label: 'Fecha de nacimiento', value: personal!['date_of_birth'] as String),
                      _InfoRow(label: 'CI', value: personal['national_id'] as String),
                      _InfoRow(label: 'Dirección', value: personal['address'] as String),
                      _InfoRow(label: 'Ciudad', value: personal['city'] as String),
                    ]
                  : [
                      _InfoRow(label: 'Fecha de nacimiento', value: '15/06/1990'),
                      _InfoRow(label: 'Tipo de sangre', value: 'O+'),
                      _InfoRow(label: 'CI', value: '8745612'),
                    ],
            ),
            const SizedBox(height: 12),
            // Medical info
            _buildInfoCard(
              title: 'Información médica',
              icon: Icons.medical_information_outlined,
              items: kDemoMode
                  ? [
                      _InfoRow(label: 'Tipo de sangre', value: medical!['blood_type'] as String),
                      _InfoRow(label: 'Alergias', value: medical['allergies'] as String),
                      _InfoRow(label: 'Medicamentos', value: medical['medications'] as String),
                      _InfoRow(label: 'Condiciones', value: medical['conditions'] as String),
                    ]
                  : [
                      _InfoRow(label: 'Alergias', value: 'Ninguna registrada'),
                      _InfoRow(label: 'Medicamentos', value: 'Ninguno'),
                      _InfoRow(label: 'Condiciones', value: 'Ninguna registrada'),
                    ],
            ),
            const SizedBox(height: 12),
            // Notifications
            _buildNotificationsCard(),
            const SizedBox(height: 12),
            // Payment method (disabled)
            _buildDisabledCard(
              title: 'Método de pago',
              icon: Icons.payment_outlined,
              message: 'Coming soon...',
            ),
            const SizedBox(height: 20),
            // Demo mode switcher
            if (kDemoMode) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/clinic/dashboard'),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: const Text('Cambiar a vista Clínica'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KiltoColors.navy,
                    foregroundColor: KiltoColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            // Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (kDemoMode) {
                    context.go('/login');
                  } else {
                    ref.read(authStateProvider.notifier).logout();
                  }
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KiltoColors.redLight,
                  foregroundColor: KiltoColors.red,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String userName, String userEmail, String userPhone, String initials) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: KiltoColors.teal,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: KiltoColors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KiltoColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userEmail,
            style: const TextStyle(
              fontSize: 13,
              color: KiltoColors.greyText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userPhone,
            style: const TextStyle(
              fontSize: 13,
              color: KiltoColors.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoRow> items,
  }) {
    return Container(
      width: double.infinity,
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
            children: [
              Icon(icon, size: 18, color: KiltoColors.teal),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.label,
                      style: const TextStyle(
                        fontSize: 13,
                        color: KiltoColors.greyText,
                      ),
                    ),
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.navy,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_outlined, size: 18, color: KiltoColors.teal),
              SizedBox(width: 8),
              Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildToggleRow(
            'Recordatorios de citas',
            _appointmentReminders,
            (v) => setState(() => _appointmentReminders = v),
          ),
          _buildToggleRow(
            'Promociones',
            _promotions,
            (v) => setState(() => _promotions = v),
          ),
          _buildToggleRow(
            'Nuevos documentos',
            _newDocuments,
            (v) => setState(() => _newDocuments = v),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: KiltoColors.navy),
          ),
          SizedBox(
            height: 28,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: KiltoColors.teal,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledCard({
    required String title,
    required IconData icon,
    required String message,
  }) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: KiltoColors.greyText),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: KiltoColors.greyMid,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.greyText,
                ),
              ),
            ),
          ],
        ),
      ),
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

class _InfoRow {
  final String label;
  final String value;
  _InfoRow({required this.label, required this.value});
}
