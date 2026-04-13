import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../core/auth/auth_state.dart';

class StaffMoreScreen extends ConsumerWidget {
  const StaffMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Más'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Settings (disabled)
            _buildMenuItem(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              subtitle: 'Coming soon...',
              enabled: false,
              onTap: null,
            ),
            const SizedBox(height: 8),
            // Modules (disabled)
            _buildMenuItem(
              icon: Icons.extension_outlined,
              label: 'Módulos',
              subtitle: 'Coming soon...',
              enabled: false,
              onTap: null,
            ),
            const SizedBox(height: 8),
            // Logout (functional)
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Cerrar sesión',
              subtitle: null,
              enabled: true,
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: KiltoColors.navy,
                      ),
                    ),
                    content: const Text(
                      '¿Estás seguro que quieres cerrar sesión?',
                      style: TextStyle(fontSize: 14, color: KiltoColors.greyText),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: KiltoColors.greyText),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          ref.read(authStateProvider.notifier).logout();
                        },
                        child: const Text(
                          'Cerrar sesión',
                          style: TextStyle(
                            color: KiltoColors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool enabled,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final contentColor = !enabled
        ? KiltoColors.greyText
        : isDestructive
            ? KiltoColors.red
            : KiltoColors.navy;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: KiltoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KiltoColors.greyMid),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? KiltoColors.redLight
                      : KiltoColors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: contentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: contentColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: KiltoColors.greyText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (enabled)
                Icon(
                  Icons.chevron_right,
                  color: contentColor.withOpacity(0.5),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
