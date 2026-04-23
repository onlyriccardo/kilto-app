import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/feature_flags.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'core/auth/auth_providers.dart';

class KiltoApp extends ConsumerStatefulWidget {
  const KiltoApp({super.key});

  @override
  ConsumerState<KiltoApp> createState() => _KiltoAppState();
}

class _KiltoAppState extends ConsumerState<KiltoApp> {
  @override
  void initState() {
    super.initState();
    if (kCentralAuth) {
      // Hydrate from secure storage on cold start so the router can decide
      // where to land without a flash of /login.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(accountProvider.notifier).bootstrap();
        ref.read(tenantSessionProvider.notifier).bootstrap();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    // Root theme always uses the default Kilto brand. Tenant-scoped accent
    // is applied only inside the client/clinic shells (and on individual
    // pushed subscreens that opt in via ClinicAccentTheme) — so /login,
    // /clinics, /account and other root pages stay on the black brand.
    return MaterialApp.router(
      title: 'Kilto',
      theme: KiltoTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
