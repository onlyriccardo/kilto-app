import 'package:flutter/material.dart';

/// Kilto color palette, mirroring the Kilto CRM (rapydscale-platform) design system.
///
/// Canonical tokens live in the `brand*`, `bg*`, `text*`, and `status*` groups.
/// The legacy names (`navy`, `teal`, `grey`, etc.) are kept as aliases so existing
/// widgets keep compiling; migrate them opportunistically.
class KiltoColors {
  // --- Surfaces & neutrals (CRM light mode) ---
  static const bg = Color(0xFFF5F6F8);          // page background
  static const surface = Color(0xFFFFFFFF);     // cards, sheets
  static const surfaceAlt = Color(0xFFE5E7EB);  // muted surface
  static const border = Color(0xFFE5E8ED);      // hairline borders
  static const borderLight = Color(0xFFF0F2F5); // very subtle dividers

  // --- Text ---
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  // --- Brand (default Kilto accent; tenants may override later) ---
  static const brandPrimary = Color(0xFF0A0A0A);
  static const brandHover = Color(0xFF262626);
  static const brandLight = Color(0xFFECECEC);  // 7% blend of brand over white
  static const onBrand = Color(0xFFFAFAFA);

  // --- Status (CRM tokens) ---
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFFBEB);
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEF2F2);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFEFF6FF);
  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFF5F3FF);

  // --- Legacy aliases (DO NOT add new usages; migrate to canonical names) ---
  @Deprecated('Use textPrimary') static const navy = textPrimary;
  @Deprecated('Use textPrimary') static const navyLight = textPrimary;
  @Deprecated('Use brandPrimary') static const teal = brandPrimary;
  @Deprecated('Use brandHover') static const tealDark = brandHover;
  @Deprecated('Use brandLight') static const tealLight = brandLight;
  @Deprecated('Use surface') static const white = surface;
  @Deprecated('Use bg') static const grey = bg;
  @Deprecated('Use border') static const greyMid = border;
  @Deprecated('Use textSecondary') static const greyText = textSecondary;
  @Deprecated('Use textPrimary') static const dark = textPrimary;
  @Deprecated('Use success') static const green = success;
  @Deprecated('Use successLight') static const greenLight = successLight;
  @Deprecated('Use warning') static const yellow = warning;
  @Deprecated('Use warningLight') static const yellowLight = warningLight;
  @Deprecated('Use error') static const red = error;
  @Deprecated('Use errorLight') static const redLight = errorLight;
  @Deprecated('Use info') static const blue = info;
  @Deprecated('Use infoLight') static const blueLight = infoLight;
}

/// Corner radii matching the CRM's kq-panel system.
class KiltoRadii {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const pill = 100.0;
}

class KiltoTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    scaffoldBackgroundColor: KiltoColors.bg,
    colorScheme: const ColorScheme.light(
      primary: KiltoColors.brandPrimary,
      onPrimary: KiltoColors.onBrand,
      secondary: KiltoColors.textPrimary,
      onSecondary: KiltoColors.onBrand,
      surface: KiltoColors.surface,
      onSurface: KiltoColors.textPrimary,
      surfaceContainerHighest: KiltoColors.borderLight,
      outline: KiltoColors.border,
      error: KiltoColors.error,
      onError: KiltoColors.onBrand,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KiltoColors.surface,
      foregroundColor: KiltoColors.textPrimary,
      elevation: 0,
      surfaceTintColor: KiltoColors.surface,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: KiltoColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KiltoColors.brandPrimary,
        foregroundColor: KiltoColors.onBrand,
        // Explicitly also set iconColor — in some Flutter versions the icon
        // child of ElevatedButton.icon doesn't inherit `foregroundColor`, so
        // without this the QR / add icons render dark on the dark brand bg
        // and become invisible.
        iconColor: KiltoColors.onBrand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KiltoRadii.medium),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KiltoColors.textPrimary,
        side: const BorderSide(color: KiltoColors.border),
        backgroundColor: KiltoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KiltoRadii.small),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KiltoColors.textPrimary,
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: KiltoColors.surface,
      surfaceTintColor: KiltoColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.large),
        side: const BorderSide(color: KiltoColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KiltoColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.medium),
        borderSide: const BorderSide(color: KiltoColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.medium),
        borderSide: const BorderSide(color: KiltoColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.medium),
        borderSide: const BorderSide(color: KiltoColors.brandPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.medium),
        borderSide: const BorderSide(color: KiltoColors.error),
      ),
      hintStyle: const TextStyle(color: KiltoColors.textTertiary),
      labelStyle: const TextStyle(color: KiltoColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: KiltoColors.surface,
      selectedItemColor: KiltoColors.brandPrimary,
      unselectedItemColor: KiltoColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w600,
        fontSize: 10,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'DMSans',
        fontWeight: FontWeight.w400,
        fontSize: 10,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: KiltoColors.border,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: KiltoColors.borderLight,
      labelStyle: const TextStyle(
        fontFamily: 'DMSans',
        color: KiltoColors.textPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      side: const BorderSide(color: KiltoColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
  );
}
