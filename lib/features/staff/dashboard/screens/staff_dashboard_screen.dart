import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class StaffDashboardScreen extends StatelessWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Cards
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    label: 'Total Contactos',
                    value: '248',
                    icon: Icons.people_outline,
                    iconColor: KiltoColors.teal,
                    iconBg: KiltoColors.tealLight,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKpiCard(
                    label: 'Citas hoy',
                    value: '12',
                    icon: Icons.calendar_today,
                    iconColor: KiltoColors.blue,
                    iconBg: KiltoColors.blueLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildKpiCard(
              label: 'Deals abiertos',
              value: '34',
              icon: Icons.handshake_outlined,
              iconColor: KiltoColors.green,
              iconBg: KiltoColors.greenLight,
              fullWidth: true,
            ),
            const SizedBox(height: 32),
            // Coming soon
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: KiltoColors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.dashboard_customize_outlined,
                      size: 36,
                      color: KiltoColors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dashboard completo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gráficos, métricas y reportes estarán disponibles próximamente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: KiltoColors.greyText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: KiltoColors.yellowLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Coming soon...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.yellow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: KiltoColors.navy,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: KiltoColors.greyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
