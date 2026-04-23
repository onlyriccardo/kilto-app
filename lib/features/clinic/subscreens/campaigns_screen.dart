import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Clinic marketing campaigns. Fetched from /v1/clinic/campaigns. Backend
/// currently returns empty lists until the Campaign model is integrated.
class CampaignsScreen extends ConsumerWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicCampaignsProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Campañas'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar las campañas\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (d) {
          final k = (d['kpis'] as Map?)?.cast<String, dynamic>() ?? {};
          final campaigns = ((d['campaigns'] as List?) ?? [])
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clinicCampaignsProvider),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    children: [
                      _kpiCard('Enviados', '${k['total_sent'] ?? 0}',
                          KiltoColors.blue),
                      _kpiCard('Tasa apertura', '${k['open_rate'] ?? 0}%',
                          KiltoColors.green),
                      _kpiCard('Tasa clic', '${k['click_rate'] ?? 0}%',
                          Theme.of(context).colorScheme.primary),
                      _kpiCard('Activas', '${k['active'] ?? 0}',
                          KiltoColors.yellow),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Campañas',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy),
                  ),
                  const SizedBox(height: 12),
                  if (campaigns.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: KiltoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KiltoColors.greyMid),
                      ),
                      child: const Center(
                        child: Text(
                          'Aún no hay campañas. Podrás crear tu primera campaña cuando el módulo de marketing esté activo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: KiltoColors.greyText),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: KiltoColors.greyText,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: accent)),
        ],
      ),
    );
  }
}
