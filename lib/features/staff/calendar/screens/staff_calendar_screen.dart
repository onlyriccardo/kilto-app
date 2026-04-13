import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

class StaffCalendarScreen extends StatelessWidget {
  const StaffCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Calendario'),
        centerTitle: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                  Icons.calendar_month_rounded,
                  size: 36,
                  color: KiltoColors.teal,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Calendario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: KiltoColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coming soon \u2014 calendar management',
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
    );
  }
}
