import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../subscreens/campaigns_screen.dart';
import '../../subscreens/finances_screen.dart';
import '../../subscreens/clinic_notifications_screen.dart';
import '../../subscreens/team_screen.dart';
import '../../subscreens/services_screen.dart';
import '../../subscreens/settings_screen.dart';

class ClinicMoreScreen extends StatelessWidget {
  const ClinicMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      _MenuItem(
        emoji: '\u{1F4E2}',
        label: 'Campa\u00f1as',
        description: 'WhatsApp, SMS, email',
        screen: const CampaignsScreen(),
      ),
      _MenuItem(
        emoji: '\u{1F4B0}',
        label: 'Finanzas',
        description: 'Ingresos, pagos, deudas',
        screen: const FinancesScreen(),
      ),
      _MenuItem(
        emoji: '\u{1F514}',
        label: 'Notificaciones',
        description: 'Alertas y avisos',
        screen: const ClinicNotificationsScreen(),
      ),
      _MenuItem(
        emoji: '\u{1F465}',
        label: 'Equipo',
        description: 'Doctores y staff',
        screen: const TeamScreen(),
      ),
      _MenuItem(
        emoji: '\u{1F9B7}',
        label: 'Servicios',
        description: 'Cat\u00e1logo de servicios',
        screen: const ServicesScreen(),
      ),
      _MenuItem(
        emoji: '\u2699\uFE0F',
        label: 'Configuraci\u00f3n',
        description: 'Datos de la cl\u00ednica',
        screen: const SettingsScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'M\u00e1s',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: KiltoColors.navy,
                ),
              ),
              const SizedBox(height: 20),
              // Menu grid
              ...menuItems.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => item.screen),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: KiltoColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KiltoColors.greyMid),
                    ),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: KiltoColors.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KiltoColors.greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: KiltoColors.greyText, size: 20),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Demo mode switcher
              if (kDemoMode)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/client/home'),
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      label: const Text('Cambiar a vista Cliente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KiltoColors.teal,
                        foregroundColor: KiltoColors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              // Footer
              Center(
                child: Text(
                  'Powered by kilto \u00b7 v1.0.4',
                  style: TextStyle(
                    fontSize: 12,
                    color: KiltoColors.greyText.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String emoji;
  final String label;
  final String description;
  final Widget screen;

  _MenuItem({
    required this.emoji,
    required this.label,
    required this.description,
    required this.screen,
  });
}
