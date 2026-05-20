import 'package:flutter/material.dart';
import '../../config/clinic_theme.dart';
import '../../config/theme.dart';

/// Gradient "hero" card used to spotlight one item (the next appointment on
/// the home screen, today's highlight on the clinic dashboard, etc).
///
/// The gradient runs from the active accent into a 14% lighter tint of it,
/// using the clinic's brand color via [ClinicAccentExtension] (falls back to
/// the Kilto default brand outside a clinic shell). The shadow is tinted to
/// match — same recipe the mockup uses.
class KiltoHeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Optional explicit accent. Defaults to the active clinic accent.
  final Color? accent;

  const KiltoHeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final extension = Theme.of(context).extension<ClinicAccentExtension>();
    final base = accent ?? extension?.accent ?? KiltoColors.brandPrimary;
    final lighter = Color.alphaBlend(Colors.white.withValues(alpha: 0.14), base);

    final radius = BorderRadius.circular(KiltoRadii.medium);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, lighter],
        ),
        borderRadius: radius,
        boxShadow: KiltoShadows.hero(base),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Soft top-right halo, like the mockup.
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
