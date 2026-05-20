import 'package:flutter/material.dart';
import 'kilto_text.dart';

/// Uppercase eyebrow used to label a section ("CITAS PRÓXIMAS", "AYUDA").
///
/// Renders with the standard 6px bottom padding so adjacent content can sit
/// flush below.
class KiltoSectionHeader extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;

  const KiltoSectionHeader(
    this.text, {
    super.key,
    this.padding =
        const EdgeInsets.only(left: 4, right: 4, bottom: 6, top: 0),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(child: KiltoText.eyebrow(text)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
