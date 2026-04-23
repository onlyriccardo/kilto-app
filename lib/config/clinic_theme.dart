import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_providers.dart';
import 'theme.dart';

/// The accent color of the clinic the user is currently inside. Falls back
/// to the default Kilto brand when outside a clinic or when the clinic
/// hasn't customized its branding.
final clinicAccentProvider = Provider<Color>((ref) {
  final membership = ref.watch(tenantSessionProvider).membership;
  return membership?.brandColor ?? KiltoColors.brandPrimary;
});

/// Wraps a subtree in a Theme whose primary / brand colors are overridden
/// with the active clinic's accent. Used inside the tenant shells so every
/// ElevatedButton, OutlinedButton, tab indicator, etc. picks up the accent
/// without the rest of the app needing to know about it.
class ClinicAccentTheme extends ConsumerWidget {
  final Widget child;
  const ClinicAccentTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = ref.watch(clinicAccentProvider);
    return Theme(
      data: applyAccent(Theme.of(context), accent),
      child: child,
    );
  }

  /// Returns a derivative of [base] with all brand surfaces (buttons, tabs,
  /// FAB, progress, colorScheme) swapped for [accent]. Public so the root
  /// [MaterialApp] can apply it too, which ensures pushed routes (not
  /// inside the ShellRoute) also inherit the accent.
  static ThemeData applyAccent(ThemeData base, Color accent) {
    // Compute a lighter variant for "light" fills (badges, empty-state bg).
    final lighter = Color.alphaBlend(accent.withOpacity(0.12), Colors.white);
    final onAccent = _pickOnColor(accent);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        onPrimary: onAccent,
        secondary: accent,
        onSecondary: onAccent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: (base.elevatedButtonTheme.style ?? const ButtonStyle())
            .copyWith(
          backgroundColor: WidgetStatePropertyAll(accent),
          foregroundColor: WidgetStatePropertyAll(onAccent),
          iconColor: WidgetStatePropertyAll(onAccent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: (base.outlinedButtonTheme.style ?? const ButtonStyle())
            .copyWith(
          foregroundColor: WidgetStatePropertyAll(accent),
          iconColor: WidgetStatePropertyAll(accent),
          side: WidgetStatePropertyAll(
              BorderSide(color: accent.withOpacity(0.35))),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: (base.textButtonTheme.style ?? const ButtonStyle())
            .copyWith(
          foregroundColor: WidgetStatePropertyAll(accent),
          iconColor: WidgetStatePropertyAll(accent),
        ),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: accent,
        indicatorColor: accent,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: accent,
        foregroundColor: onAccent,
      ),
      progressIndicatorTheme:
          base.progressIndicatorTheme.copyWith(color: accent),
      // A very-light tint used by the next-appointment card badge etc.
      extensions: [
        ClinicAccentExtension(accent: accent, lighter: lighter, onAccent: onAccent),
      ],
    );
  }

  /// Pick black-or-white foreground based on the accent's luminance.
  static Color _pickOnColor(Color bg) =>
      bg.computeLuminance() > 0.55 ? Colors.black : Colors.white;
}

/// Theme extension so screens can read the computed accent-related colors
/// without re-parsing the raw hex. `Theme.of(context).extension<ClinicAccentExtension>()`.
class ClinicAccentExtension extends ThemeExtension<ClinicAccentExtension> {
  final Color accent;
  final Color lighter;
  final Color onAccent;

  const ClinicAccentExtension({
    required this.accent,
    required this.lighter,
    required this.onAccent,
  });

  @override
  ClinicAccentExtension copyWith({
    Color? accent,
    Color? lighter,
    Color? onAccent,
  }) =>
      ClinicAccentExtension(
        accent: accent ?? this.accent,
        lighter: lighter ?? this.lighter,
        onAccent: onAccent ?? this.onAccent,
      );

  @override
  ClinicAccentExtension lerp(
      covariant ClinicAccentExtension? other, double t) {
    if (other == null) return this;
    return ClinicAccentExtension(
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      lighter: Color.lerp(lighter, other.lighter, t) ?? lighter,
      onAccent: Color.lerp(onAccent, other.onAccent, t) ?? onAccent,
    );
  }
}
