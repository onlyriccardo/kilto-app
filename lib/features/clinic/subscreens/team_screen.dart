import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Clinic team directory. Fetched from /v1/clinic/team. Read-only for now —
/// invite/role-edit flows will come after TeamMember.role is formalized.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ClinicAccentTheme(child: _buildContent(context, ref));

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicTeamProvider);
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(title: const Text('Equipo'), centerTitle: false),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No se pudo cargar el equipo\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: KiltoColors.greyText)),
          ),
        ),
        data: (members) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(clinicTeamProvider),
          child: members.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Aún no hay miembros en el equipo.',
                          style: TextStyle(color: KiltoColors.greyText),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: members.length,
                  itemBuilder: (context, i) => _memberCard(context, members[i]),
                ),
        ),
      ),
    );
  }

  Widget _memberCard(BuildContext context, Map<String, dynamic> m) {
    final role = m['role'] as String? ?? 'staff';
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              m['initials'] as String? ?? '??',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['name'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.navy)),
                const SizedBox(height: 2),
                Text(m['email'] as String? ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: KiltoColors.greyText)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: KiltoColors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(role,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.greyText)),
          ),
        ],
      ),
    );
  }
}
