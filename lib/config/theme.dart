import 'package:flutter/material.dart';

class KiltoColors {
  static const navy = Color(0xFF1B2A4A);
  static const navyLight = Color(0xFF2A3D5F);
  static const teal = Color(0xFF2EC4B6);
  static const tealDark = Color(0xFF25A89C);
  static const tealLight = Color(0xFFE8FAF8);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color(0xFFF5F7FA);
  static const greyMid = Color(0xFFE2E8F0);
  static const greyText = Color(0xFF94A3B8);
  static const dark = Color(0xFF0F172A);
  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFDCFCE7);
  static const yellow = Color(0xFFEAB308);
  static const yellowLight = Color(0xFFFEF9C3);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const blue = Color(0xFF3B82F6);
  static const blueLight = Color(0xFFDBEAFE);
}

class KiltoTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'DMSans',
    scaffoldBackgroundColor: KiltoColors.grey,
    colorScheme: ColorScheme.light(
      primary: KiltoColors.teal,
      onPrimary: KiltoColors.white,
      secondary: KiltoColors.navy,
      onSecondary: KiltoColors.white,
      surface: KiltoColors.white,
      onSurface: KiltoColors.navy,
      error: KiltoColors.red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: KiltoColors.white,
      foregroundColor: KiltoColors.navy,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'DMSans',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: KiltoColors.navy,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KiltoColors.teal,
        foregroundColor: KiltoColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KiltoColors.navy,
        side: const BorderSide(color: KiltoColors.greyMid),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    cardTheme: CardTheme(
      color: KiltoColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: KiltoColors.greyMid),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KiltoColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KiltoColors.greyMid),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KiltoColors.greyMid),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: KiltoColors.teal, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: KiltoColors.white,
      selectedItemColor: KiltoColors.teal,
      unselectedItemColor: KiltoColors.greyText,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w600, fontSize: 10),
      unselectedLabelStyle: TextStyle(fontFamily: 'DMSans', fontWeight: FontWeight.w400, fontSize: 10),
    ),
  );
}
