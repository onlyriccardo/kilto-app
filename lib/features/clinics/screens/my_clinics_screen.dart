import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/kilto_wordmark.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/account.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/widgets/kilto_card.dart';
import '../../../core/widgets/kilto_empty_state.dart';
import '../../../core/widgets/kilto_section_header.dart';
import '../../../core/widgets/kilto_text.dart';

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
    // Re-fetch the clinics list whenever anything bumps the version provider
    // (e.g. the install-code join flow does this on success).
    ref.listen<int>(clinicsListVersionProvider, (_, __) => _refresh());

    final account = ref.watch(accountProvider).account;
    final firstName = (account?.name?.split(' ').first ?? '').trim();

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<ClinicMembership>>(
            future: _future,
            builder: (context, snapshot) {
              final clinics = snapshot.data ?? const <ClinicMembership>[];
              final loading =
                  snapshot.connectionState == ConnectionState.waiting &&
                      clinics.isEmpty;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  _Header(onAccount: () => context.push('/account')),
                  const SizedBox(height: 28),
                  if (firstName.isNotEmpty)
                    KiltoText.label('Hola, $firstName 👋'),
                  const SizedBox(height: 2),
                  KiltoText.h1(
                    clinics.isEmpty
                        ? 'Conecta a tu clínica'
                        : 'Tus clínicas',
                  ),
                  const SizedBox(height: 24),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (clinics.isEmpty)
                    KiltoEmptyState(
                      icon: Icons.local_hospital_outlined,
                      title: 'Aún no tienes clínicas',
                      subtitle:
                          'Escanea el QR de tu clínica o pide el código para conectarte.',
                    )
                  else ...[
                    const KiltoSectionHeader('Activas'),
                    for (final m in clinics) ...[
                      _ClinicRow(membership: m, onTap: () => _enter(m)),
                      const SizedBox(height: 10),
                    ],
                  ],
                  const SizedBox(height: 28),
                  const KiltoSectionHeader('Conectar otra clínica'),
                  Row(
                    children: [
                      Expanded(
                        child: _ConnectTile(
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Escanear QR',
                          subtitle: 'Rápido y sin escribir',
                          primary: true,
                          onTap: () => context.push('/clinics/scan'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ConnectTile(
                          icon: Icons.keyboard_rounded,
                          title: 'Código',
                          subtitle: '8 dígitos',
                          primary: false,
                          onTap: () => context.push('/clinics/enter-code'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAccount;
  const _Header({required this.onAccount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const KiltoWordmark(iconSize: 26),
        const Spacer(),
        Material(
          color: KiltoColors.surface,
          shape: const CircleBorder(
            side: BorderSide(color: KiltoColors.border, width: 1),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onAccount,
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.person_outline_rounded,
                  size: 18, color: KiltoColors.zinc700),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClinicRow extends StatelessWidget {
  final ClinicMembership membership;
  final VoidCallback onTap;
  const _ClinicRow({required this.membership, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return KiltoCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _ClinicAvatar(membership: membership),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KiltoText.strong(membership.tenantName, size: 14),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _RolePill(role: membership.role),
                    if (membership.status != 'active') ...[
                      const SizedBox(width: 6),
                      _StatusPill(status: membership.status),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: KiltoColors.zinc400, size: 20),
        ],
      ),
    );
  }
}

class _ClinicAvatar extends StatelessWidget {
  final ClinicMembership membership;
  const _ClinicAvatar({required this.membership});

  @override
  Widget build(BuildContext context) {
    final initial = membership.tenantName.isNotEmpty
        ? membership.tenantName[0].toUpperCase()
        : '?';
    final brand = membership.brandColor;
    final bg = brand ?? KiltoColors.brandPrimary;
    final fg = brand == null
        ? KiltoColors.onBrand
        : (brand.computeLuminance() > 0.55 ? Colors.black : Colors.white);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bg, Color.alphaBlend(Colors.white.withValues(alpha: 0.14), bg)],
        ),
        borderRadius: BorderRadius.circular(KiltoRadii.small),
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w900,
          fontSize: 18,
          color: fg,
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    final isStaff = role == 'staff';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isStaff ? KiltoColors.infoLight : KiltoColors.zinc100,
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
      ),
      child: Text(
        isStaff ? 'Staff' : 'Cliente',
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: isStaff ? KiltoColors.info : KiltoColors.zinc600,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending_approval' => KiltoColors.warning,
      'disabled' => KiltoColors.error,
      _ => KiltoColors.zinc600,
    };
    final bg = switch (status) {
      'pending_approval' => KiltoColors.warningLight,
      'disabled' => KiltoColors.errorLight,
      _ => KiltoColors.zinc100,
    };
    final label = switch (status) {
      'pending_approval' => 'Pendiente',
      'disabled' => 'Deshabilitado',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: color,
        ),
      ),
    );
  }
}

class _ConnectTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool primary;
  final VoidCallback onTap;

  const _ConnectTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(KiltoRadii.medium);
    final bg = primary ? KiltoColors.brandPrimary : KiltoColors.surface;
    final fg = primary ? KiltoColors.onBrand : KiltoColors.zinc950;
    final sub = primary ? Colors.white.withValues(alpha: 0.7) : KiltoColors.zinc500;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: primary
                ? null
                : Border.all(color: KiltoColors.border, width: 1),
            boxShadow: primary ? KiltoShadows.ctaPrimary : KiltoShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primary
                        ? Colors.white.withValues(alpha: 0.18)
                        : KiltoColors.zinc100,
                    borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                  ),
                  child: Icon(icon, size: 18, color: fg),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: KiltoFonts.familyHeading,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: KiltoFonts.familyBody,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: sub,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
