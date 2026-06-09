import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  // Display/Headline: Lexend
  static TextStyle get displayLarge => GoogleFonts.lexend(
    fontSize: 57,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.5,
    color: AppColors.onSurface,
  );

  static TextStyle get displayMedium => GoogleFonts.lexend(
    fontSize: 45,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: AppColors.onSurface,
  );

  static TextStyle get displaySmall => GoogleFonts.lexend(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineLarge => GoogleFonts.lexend(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineMedium => GoogleFonts.lexend(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineSmall => GoogleFonts.lexend(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Body & UI Label: Plus Jakarta Sans
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.onSurface,
  );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: AppColors.onSurfaceVariant,
  );
}
