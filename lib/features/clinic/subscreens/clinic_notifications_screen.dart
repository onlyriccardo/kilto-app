import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_data.dart';

class ClinicNotificationsScreen extends StatelessWidget {
  const ClinicNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: DemoData.clinicNotifications.length,
        itemBuilder: (context, index) {
          final notification = DemoData.clinicNotifications[index];
          final isUnread = notification['unread'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isUnread
                  ? KiltoColors.tealLight.withOpacity(0.3)
                  : KiltoColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: const BoxDecoration(
                      color: KiltoColors.teal,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(width: 16),
                Text(
                  notification['icon'] as String,
                  style: const TextStyle(fontSize: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                          color: KiltoColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: KiltoColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
