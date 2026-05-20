import 'package:flutter/material.dart';
import '../../config/clinic_theme.dart';
import '../../config/theme.dart';

/// Stacked month / day badge used in appointment lists.
///
/// Looks like:
///   ┌─────┐
///   │ MAY │
///   │ 20  │
///   └─────┘
///
/// Tinted with the active clinic accent so each clinic gets its own color.
/// Pass an explicit [accent] to override (e.g. in lists that show different
/// clinics).
class KiltoDateBadge extends StatelessWidget {
  final DateTime date;
  final double size;
  final Color? accent;

  /// Locale for the month abbreviation. Defaults to Spanish 3-letter month
  /// names since that's the app's primary language.
  final String locale;

  const KiltoDateBadge({
    super.key,
    required this.date,
    this.size = 44,
    this.accent,
    this.locale = 'es',
  });

  static const _esMonths = [
    'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
    'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC',
  ];

  String get _monthLabel {
    final idx = (date.month - 1).clamp(0, 11);
    return _esMonths[idx];
  }

  String get _dayLabel => date.day.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<ClinicAccentExtension>();
    final base = accent ?? extension?.accent ?? KiltoColors.brandPrimary;
    final tint = Color.alphaBlend(base.withValues(alpha: 0.12), Colors.white);
    final fg = _readableForeground(base);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(KiltoRadii.small),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _monthLabel,
            style: TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontWeight: FontWeight.w800,
              fontSize: 9,
              letterSpacing: 0.6,
              color: fg,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            _dayLabel,
            style: TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              height: 1.0,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// For light tints we want a darker readable foreground (the accent itself,
  /// nudged darker if it's already pale).
  static Color _readableForeground(Color accent) {
    if (accent.computeLuminance() > 0.7) {
      return KiltoColors.zinc900;
    }
    return accent;
  }
}
