import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme.dart';
import '../../../core/auth/auth_providers.dart';

/// Root-level account screen — available without a clinic context. Lets the
/// user see who they're signed in as and log out of the Kilto identity entirely.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider).account;

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      appBar: AppBar(title: const Text('Cuenta')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account?.name?.isNotEmpty == true
                          ? account!.name!
                          : 'Usuario Kilto',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account?.email ?? '—',
                      style: const TextStyle(
                        fontSize: 14,
                        color: KiltoColors.textSecondary,
                      ),
                    ),
                    if (account?.phone != null &&
                        account!.phone!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        account.phone!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: KiltoColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(accountProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: KiltoColors.error,
                side: const BorderSide(color: KiltoColors.error),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
