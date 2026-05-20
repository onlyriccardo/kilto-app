import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/theme.dart';

/// K° rounded-square icon + "Kilto" text, side by side or stacked.
///
/// We build this in Flutter widgets instead of using the wordmark SVG because
/// the wordmark SVG uses nested `<svg>` elements which `flutter_svg` doesn't
/// render — only the text part comes through. This widget gives us the full
/// brand mark every time.
class KiltoWordmark extends StatelessWidget {
  final double iconSize;
  final double? textSize;
  final Color textColor;
  final Axis direction;
  final double gap;

  const KiltoWordmark({
    super.key,
    this.iconSize = 28,
    this.textSize,
    this.textColor = KiltoColors.zinc950,
    this.direction = Axis.horizontal,
    this.gap = 8,
  });

  @override
  Widget build(BuildContext context) {
    final txt = Text(
      'Kilto',
      style: TextStyle(
        fontFamily: KiltoFonts.familyHeading,
        fontSize: textSize ?? (iconSize * 0.62),
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
        color: textColor,
        height: 1.0,
      ),
    );
    final icon = SvgPicture.asset(
      'assets/brand/kilto-favicon.svg',
      height: iconSize,
      width: iconSize,
      semanticsLabel: 'Kilto',
    );

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [icon, SizedBox(width: gap), txt],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [icon, SizedBox(height: gap), txt],
    );
  }
}
