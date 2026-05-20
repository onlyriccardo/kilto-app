import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// The base "card" surface used across the redesigned screens.
///
/// Renders a [Material] + [InkWell] (so taps get a ripple) inside a
/// [Container] with the standard 1px zinc border and the soft
/// [KiltoShadows.card] elevation. Override [shadow] to suppress / replace
/// the default. Pass [onTap] to make the card tappable.
class KiltoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color background;
  final List<BoxShadow>? shadow;
  final BorderRadius radius;
  final Border? border;

  const KiltoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.background = KiltoColors.surface,
    this.shadow,
    BorderRadius? radius,
    this.border,
  }) : radius = radius ?? const BorderRadius.all(Radius.circular(KiltoRadii.medium));

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = border ??
        Border.all(color: KiltoColors.border, width: 1);

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: effectiveBorder,
        boxShadow: shadow ?? KiltoShadows.card,
      ),
      child: Padding(padding: padding, child: child),
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
