import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_data.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Servicios'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: DemoData.services.length,
        itemBuilder: (context, index) {
          final service = DemoData.services[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KiltoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: KiltoColors.greyMid),
            ),
            child: Row(
              children: [
                Text(
                  service['icon'] as String,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: KiltoColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 13, color: KiltoColors.greyText),
                          const SizedBox(width: 4),
                          Text(
                            service['duration'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: KiltoColors.greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  service['price'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.teal,
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
