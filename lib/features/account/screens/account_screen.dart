import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/widgets/kilto_card.dart';
import '../../../core/widgets/kilto_section_header.dart';
import '../../../core/widgets/kilto_text.dart';

/// Root-level account screen — available without a clinic context. Lets the
/// user see who they're signed in as and log out of the Kilto identity entirely.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider).account;
    final name = account?.name?.isNotEmpty == true ? account!.name! : 'Usuario Kilto';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'K';

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.canPop() ? context.pop() : context.go('/clinics'),
                  icon: const Icon(Icons.arrow_back_rounded, color: KiltoColors.zinc900),
                  style: IconButton.styleFrom(
                    backgroundColor: KiltoColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                      side: const BorderSide(color: KiltoColors.border),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                KiltoText.h3('Cuenta'),
              ],
            ),
            const SizedBox(height: 20),
            KiltoCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [KiltoColors.brandPrimary, KiltoColors.zinc700],
                      ),
                      borderRadius: BorderRadius.circular(KiltoRadii.small),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontFamily: KiltoFonts.familyHeading,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: KiltoColors.onBrand,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KiltoText.strong(name, size: 15),
                        const SizedBox(height: 2),
                        KiltoText.body(account?.email ?? '—',
                            color: KiltoColors.zinc500, size: 12.5),
                        if (account?.phone != null && account!.phone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          KiltoText.body(account.phone!,
                              color: KiltoColors.zinc500, size: 12.5),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const KiltoSectionHeader('Acciones'),
            KiltoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.business_outlined,
                    label: 'Mis clínicas',
                    onTap: () => context.go('/clinics'),
                  ),
                  const Divider(height: 1, color: KiltoColors.borderLight),
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Cerrar sesión',
                    danger: true,
                    onTap: () async {
                      await ref.read(accountProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const KiltoSectionHeader('Zona peligrosa'),
            KiltoCard(
              padding: EdgeInsets.zero,
              child: _ActionTile(
                icon: Icons.delete_forever_outlined,
                label: 'Eliminar cuenta',
                danger: true,
                onTap: () => _confirmDelete(context, ref),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: KiltoText.body(
                'Esta acción es permanente. Se eliminarán tu cuenta, tus '
                'clínicas conectadas y tu historial.',
                color: KiltoColors.zinc500,
                size: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        backgroundColor: KiltoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KiltoRadii.medium),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: KiltoColors.errorLight,
                  borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.warning_amber_rounded,
                    color: KiltoColors.error, size: 22),
              ),
              const SizedBox(height: 14),
              KiltoText.h3('¿Eliminar tu cuenta?'),
              const SizedBox(height: 6),
              KiltoText.body(
                'Esta acción es permanente y no se puede deshacer. Se '
                'eliminarán tu cuenta Kilto, todas tus conexiones a clínicas '
                'y tu historial asociado.',
                color: KiltoColors.zinc600,
                size: 13,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: KiltoColors.border),
                        foregroundColor: KiltoColors.zinc900,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(KiltoRadii.xsmall),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: KiltoColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(KiltoRadii.xsmall),
                        ),
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(accountProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      context.go('/login');
      messenger.showSnackBar(
        const SnackBar(content: Text('Tu cuenta fue eliminada.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la cuenta: $e')),
      );
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? KiltoColors.error : KiltoColors.zinc900;
    final bg = danger ? KiltoColors.errorLight : KiltoColors.zinc100;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KiltoText.strong(label, size: 13, color: color),
              ),
              if (!danger)
                const Icon(Icons.chevron_right_rounded,
                    size: 18, color: KiltoColors.zinc400),
            ],
          ),
        ),
      ),
    );
  }
}
