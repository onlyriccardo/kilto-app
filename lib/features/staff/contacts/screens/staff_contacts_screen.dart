import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class StaffContactsScreen extends StatelessWidget {
  const StaffContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Contactos'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: 'Buscar contactos...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: KiltoColors.greyText,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: KiltoColors.greyText,
                  size: 20,
                ),
                filled: true,
                fillColor: KiltoColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KiltoColors.greyMid),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KiltoColors.greyMid),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: KiltoColors.greyMid),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Coming soon
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: KiltoColors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        size: 36,
                        color: KiltoColors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Gestión de contactos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Coming soon \u2014 full contact management',
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
            ),
          ],
        ),
      ),
    );
  }
}
