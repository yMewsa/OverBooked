import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central theme definition for the Overbooked app.
/// All colors and typography are defined here for consistency.
class AppTheme {
  AppTheme._();

  // ── Color Palette ──────────────────────────────────────────────────────────

  /// Warm cream/parchment — primary background
  static const Color background = Color(0xFFFAF7F2);

  /// Lighter parchment — card and surface backgrounds
  static const Color surface = Color(0xFFF5F0E8);

  /// Deep charcoal — primary text and icons
  static const Color primary = Color(0xFF2C2623);

  /// Golden amber — accent, selected states, badges
  static const Color accent = Color(0xFFC68B3A);

  /// Walnut brown — shelf dividers and decorative elements
  static const Color shelfWood = Color(0xFF8B5E3C);

  /// Warm gray-brown — secondary/hint text
  static const Color secondaryText = Color(0xFF7A6A5A);

  /// Soft warm border
  static const Color divider = Color(0xFFE8DDD0);

  /// Muted green — success / "read" actions
  static const Color success = Color(0xFF4A7C59);

  /// Muted red — errors and destructive actions
  static const Color error = Color(0xFFB94A48);

  // ── Theme ──────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        onPrimary: Colors.white,
        secondary: shelfWood,
        surface: surface,
        onSurface: primary,
        error: error,
      ),

      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.libreCaslonText(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        displayMedium: GoogleFonts.libreCaslonText(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleLarge: GoogleFonts.libreCaslonText(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.libreCaslonText(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: accent,
        unselectedItemColor: secondaryText,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: divider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 0,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
      ),
    );
  }
}
