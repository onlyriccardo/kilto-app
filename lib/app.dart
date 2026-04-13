import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class KiltoApp extends ConsumerWidget {
  const KiltoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Kilto',
      theme: KiltoTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
