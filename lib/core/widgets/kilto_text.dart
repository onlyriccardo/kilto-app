import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Typography helpers that match the mockup's tight, Outfit-headed style.
///
/// Use these instead of writing fresh `TextStyle` literals — they centralize
/// font family / weight / letter-spacing decisions so a future tweak to the
/// scale is a single-file edit.
class KiltoText {
  KiltoText._();

  /// Page hero (e.g. "Bienvenido", "Tus clínicas").
  static Text h1(String text, {Color? color, TextAlign? align}) => Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w900,
          fontSize: 26,
          height: 1.05,
          letterSpacing: -0.5,
          color: color ?? KiltoColors.zinc950,
        ),
      );

  /// Section hero (e.g. "Tus próximas citas").
  static Text h2(String text, {Color? color, TextAlign? align}) => Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          height: 1.05,
          letterSpacing: -0.4,
          color: color ?? KiltoColors.zinc950,
        ),
      );

  /// Card title.
  static Text h3(String text, {Color? color, TextAlign? align}) => Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w800,
          fontSize: 18,
          height: 1.15,
          letterSpacing: -0.2,
          color: color ?? KiltoColors.zinc950,
        ),
      );

  /// Bold inline label (button-style without a background).
  static Text strong(String text,
          {Color? color, double size = 13, TextAlign? align}) =>
      Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w800,
          fontSize: size,
          letterSpacing: -0.1,
          color: color ?? KiltoColors.zinc950,
        ),
      );

  /// Uppercase tiny eyebrow ("CORREO", "PRÓXIMA CITA · EN 2 DÍAS").
  static Text eyebrow(String text, {Color? color}) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: KiltoFonts.familyHeading,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.2,
          color: color ?? KiltoColors.zinc500,
        ),
      );

  /// Default body copy.
  static Text body(
    String text, {
    Color? color,
    double size = 13,
    FontWeight weight = FontWeight.w500,
    TextAlign? align,
    int? maxLines,
    TextOverflow? overflow,
  }) =>
      Text(
        text,
        textAlign: align,
        maxLines: maxLines,
        overflow: overflow,
        style: TextStyle(
          fontFamily: KiltoFonts.familyBody,
          fontWeight: weight,
          fontSize: size,
          height: 1.45,
          color: color ?? KiltoColors.zinc700,
        ),
      );

  /// Muted secondary label (sub-line under a title, helper text).
  static Text label(String text,
          {Color? color, double size = 11, TextAlign? align}) =>
      Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: KiltoFonts.familyBody,
          fontWeight: FontWeight.w500,
          fontSize: size,
          color: color ?? KiltoColors.zinc500,
        ),
      );
}
