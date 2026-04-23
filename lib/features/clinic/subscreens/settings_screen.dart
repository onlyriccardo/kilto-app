import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Clinic settings — shows read-only tenant info fetched from
/// /v1/clinic/settings. The Branding/modules blocks come from the same
/// payload. Edit flow is not wired yet.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicSettingsProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Configuración'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudieron cargar los ajustes\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (s) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(clinicSettingsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _card(
                  context,
                  icon: Icons.business,
                  title: 'Datos de la clínica',
                  children: [
                    _row('Nombre', s['name'] as String? ?? '—'),
                    _row('Slug', s['slug'] as String? ?? '—'),
                    _row('Teléfono', s['phone'] as String? ?? '—'),
                    _row('Email', s['email'] as String? ?? '—'),
                    _row('Dirección', s['address'] as String? ?? '—'),
                  ],
                ),
                const SizedBox(height: 16),
                _card(
                  context,
                  icon: Icons.dashboard_customize_outlined,
                  title: 'Módulos activos',
                  children: [
                    if (((s['active_modules'] as List?) ?? const []).isEmpty)
                      const Text('Ningún módulo activo',
                          style: TextStyle(color: KiltoColors.greyText))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ((s['active_modules'] as List?) ?? [])
                            .map((m) => Chip(
                                  label: Text('$m'),
                                  backgroundColor: Color.alphaBlend(
                                      Theme.of(context).colorScheme.primary
                                          .withOpacity(0.1),
                                      Colors.white),
                                ))
                            .toList(),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/clinics'),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Cambiar de clínica'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) =>
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
            Row(
              children: [
                Icon(icon,
                    size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy)),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, color: KiltoColors.greyText)),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KiltoColors.navy)),
            ),
          ],
        ),
      );
}
