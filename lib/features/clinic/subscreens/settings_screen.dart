import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../config/demo_mode.dart';
import '../../../config/demo_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = DemoData.clinicSettings;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Configuraci\u00f3n'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Clinic data card
            Container(
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
                      Icon(Icons.business, size: 18, color: KiltoColors.teal),
                      SizedBox(width: 8),
                      Text(
                        'Datos de la cl\u00ednica',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KiltoColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _settingRow('Nombre', settings['name'] as String),
                  _settingRow('Direcci\u00f3n', settings['address'] as String),
                  _settingRow('Ciudad', settings['city'] as String),
                  _settingRow('Tel\u00e9fono', settings['phone'] as String),
                  _settingRow('Email', settings['email'] as String),
                  _settingRow('Horario', settings['hours'] as String),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Demo mode switcher
            if (kDemoMode) ...[
              SizedBox(
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
              const SizedBox(height: 10),
            ],
            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Cerrar sesi\u00f3n'),
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
            const SizedBox(height: 32),
            Text(
              'Powered by kilto',
              style: TextStyle(
                fontSize: 12,
                color: KiltoColors.greyText.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: KiltoColors.greyText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KiltoColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
