import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Clinic finances — reads /v1/clinic/finances. Payment/Invoice models
/// aren't implemented yet so the backend currently returns zero KPIs and
/// an empty transaction list; the screen renders an empty state.
class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicFinancesProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Finanzas'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar las finanzas\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (d) {
          final k = (d['kpis'] as Map?)?.cast<String, dynamic>() ?? {};
          final tx = ((d['transactions'] as List?) ?? [])
              .map((e) => (e as Map).cast<String, dynamic>())
              .toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clinicFinancesProvider),
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
                      _kpiCard('Ingresos mes', '${k['revenue_month'] ?? 0} Bs',
                          KiltoColors.green),
                      _kpiCard('Pendiente', '${k['pending'] ?? 0} Bs',
                          KiltoColors.yellow),
                      _kpiCard('Pagos hoy', '${k['today'] ?? 0} Bs',
                          Theme.of(context).colorScheme.primary),
                      _kpiCard('Con deuda', '${k['debtors_count'] ?? 0}',
                          KiltoColors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transacciones',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy),
                  ),
                  const SizedBox(height: 12),
                  if (tx.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: KiltoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KiltoColors.greyMid),
                      ),
                      child: const Center(
                        child: Text(
                          'El módulo de pagos todavía no está habilitado para esta clínica.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: KiltoColors.greyText),
                        ),
                      ),
                    )
                  else
                    ...tx.map((t) => _txRow(t, context)),
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

  Widget _txRow(Map<String, dynamic> t, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
                Text(t['patient_name'] as String? ?? '—',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.navy)),
                Text(t['service'] as String? ?? '—',
                    style: const TextStyle(
                        fontSize: 12, color: KiltoColors.greyText)),
              ],
            ),
          ),
          Text(
            t['amount'] as String? ?? '—',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
