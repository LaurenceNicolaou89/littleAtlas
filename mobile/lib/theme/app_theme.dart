import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

// ---------------------------------------------------------------------------
// Little Atlas — Soft Modern Theme
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  // ── Text Styles (standalone, usable outside the ThemeData) ──────────────

  static TextStyle get screenTitle => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionHeader => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.textSecondary,
      );

  static TextStyle get cardTitle => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get smallCaption => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get chipText => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get buttonText => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get badge => GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  static TextStyle get seeAllLink => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  // ── Light Theme ─────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      // Screen Title — 22sp Bold
      headlineLarge: screenTitle,
      // Section Header — 12sp Bold ALL CAPS
      headlineMedium: sectionHeader,
      // Card Title — 15sp SemiBold
      headlineSmall: cardTitle,
      // Body — 13sp Regular
      bodyLarge: body,
      // Caption — 12sp Medium
      bodyMedium: caption,
      // Small Caption — 11sp Regular
      bodySmall: smallCaption,
      // Button / Chip — 15sp Bold (reused for labels)
      labelLarge: buttonText.copyWith(color: AppColors.textPrimary),
      // Chip text
      labelMedium: chipText,
      // Badge
      labelSmall: badge,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,

      // ── App Bar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: screenTitle,
      ),

      // ── Bottom Navigation ────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        elevation: 0,
      ),

      // ── Cards ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardBorder,
        ),
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Chips ────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.chipBorder,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primaryWash,
        labelStyle: chipText,
        side: const BorderSide(color: AppColors.divider),
      ),

      // ── Elevated Button ──────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonBorder,
          ),
          textStyle: buttonText,
          elevation: 0,
        ),
      ),

      // ── Outlined Button ──────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonBorder,
          ),
          textStyle: buttonText.copyWith(color: AppColors.primary),
        ),
      ),

      // ── Text Button ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadii.buttonBorder,
          ),
          textStyle: buttonText.copyWith(color: AppColors.primary),
        ),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.sheetBorder,
        ),
      ),

      // ── Input / Search Bar ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: AppRadii.searchBarBorder,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.searchBarBorder,
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.searchBarBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),

      // ── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
