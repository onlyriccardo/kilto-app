import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Clinic services catalog. Fetched from /v1/clinic/services (currently
/// backed by the Product model). Read-only for now.
class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicServicesProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Servicios'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los servicios\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (services) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(clinicServicesProvider),
          child: services.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Aún no hay servicios configurados.',
                            style: TextStyle(color: KiltoColors.greyText)),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: services.length,
                  itemBuilder: (context, i) {
                    final s = services[i];
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name'] as String? ?? '',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: KiltoColors.navy)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 12, color: KiltoColors.greyText),
                                    const SizedBox(width: 4),
                                    Text('${s['duration']} min',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: KiltoColors.greyText)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            s['price'] as String? ?? '—',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
