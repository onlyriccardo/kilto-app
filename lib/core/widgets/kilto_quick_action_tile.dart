import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'kilto_text.dart';

/// Compact quick-action tile used by the home / dashboard grids.
///
/// Renders a white square with a 1px zinc border, an emoji or icon on top,
/// and a short label underneath. Designed to fit a `GridView.count` of any
/// column count (the mockup uses 3-up on phone).
class KiltoQuickActionTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? emoji;
  final IconData? icon;

  const KiltoQuickActionTile({
    super.key,
    required this.label,
    required this.onTap,
    this.emoji,
    this.icon,
  }) : assert(emoji != null || icon != null,
            'Pass either an emoji or an icon.');

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(KiltoRadii.medium);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: KiltoColors.surface,
            borderRadius: radius,
            border: Border.all(color: KiltoColors.border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (emoji != null)
                  Text(emoji!, style: const TextStyle(fontSize: 22))
                else if (icon != null)
                  Icon(icon, size: 22, color: KiltoColors.zinc900),
                const SizedBox(height: 6),
                KiltoText.strong(
                  label,
                  size: 11.5,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
