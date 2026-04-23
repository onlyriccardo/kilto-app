import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/account.dart';
import '../../../core/auth/auth_providers.dart';
import '../widgets/clinic_card.dart';

/// Root-level "My Clinics" screen — shown after login and as the app's
/// default home until the user enters a specific clinic.
class MyClinicsScreen extends ConsumerStatefulWidget {
  const MyClinicsScreen({super.key});

  @override
  ConsumerState<MyClinicsScreen> createState() => _MyClinicsScreenState();
}

class _MyClinicsScreenState extends ConsumerState<MyClinicsScreen> {
  late Future<List<ClinicMembership>> _future;

  // Guards against a double-tap race: each `enter()` call revokes the prior
  // tenant-session token on the backend, so a duplicate call nukes the token
  // we just stored and the next /v1/* request 401s.
  bool _entering = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ClinicMembership>> _load() async {
    final svc = ref.read(accountAuthServiceProvider);
    try {
      return await svc.listClinics();
    } catch (_) {
      // Fall back to last-known list when offline.
      return svc.loadCachedClinics();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _enter(ClinicMembership m) async {
    if (_entering) return;
    setState(() => _entering = true);

    final messenger = ScaffoldMessenger.of(context);
    try {
      // Always call enter() — it refreshes the tenant-session token AND
      // re-fetches the latest branding/modules. The `_entering` flag above
      // already guards against the double-tap race on the backend revoke.
      await ref.read(tenantSessionProvider.notifier).enter(m.tenantSlug);

      if (!mounted) return;
      if (m.isStaff) {
        context.go('/clinic/dashboard');
      } else {
        context.go('/client/home');
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo entrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _entering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider).account;

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      appBar: AppBar(
        // Flush left — default titleSpacing is 16 and the SVG has its own
        // small internal padding, so `0` plus a negative translate gets the
        // wordmark visually against the edge.
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Transform.translate(
          offset: const Offset(-8, 0),
          child: SvgPicture.asset(
            'assets/brand/kilto-wordmark-light.svg',
            height: 56,
          ),
        ),
        toolbarHeight: 84,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Cuenta',
            onPressed: () => context.push('/account'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ClinicMembership>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final clinics = snapshot.data ?? const <ClinicMembership>[];
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    account?.name != null && account!.name!.isNotEmpty
                        ? 'Hola, ${account.name}'
                        : 'Tus clínicas',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.textPrimary,
                    ),
                  ),
                ),
                if (clinics.isEmpty) ...[
                  const _EmptyState(),
                ] else ...[
                  for (final m in clinics) ...[
                    ClinicCard(membership: m, onTap: () => _enter(m)),
                    const SizedBox(height: 10),
                  ],
                ],
                const SizedBox(height: 20),
                const _ActionRow(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: KiltoColors.surface,
        border: Border.all(color: KiltoColors.border),
        borderRadius: BorderRadius.circular(KiltoRadii.large),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.local_hospital_outlined,
            size: 36,
            color: KiltoColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no perteneces a ninguna clínica',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: KiltoColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escanea el código QR de tu clínica o ingresa el código manualmente para unirte.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: KiltoColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/clinics/scan'),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
              label: const Text('Escanear QR'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/clinics/enter-code'),
              icon: const Icon(Icons.keyboard_rounded, size: 20),
              label: const Text('Ingresar código'),
            ),
          ),
        ),
      ],
    );
  }
}
