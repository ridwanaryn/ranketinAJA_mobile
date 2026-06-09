import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Kinetic High-Performance Editorial Palette
  static const Color primary = Color(0xFF0052D0); // Electric Velocity Blue
  static const Color primaryDim = Color(0xFF0047B7);
  static const Color primaryContainer = Color(0xFF799DFF);
  static const Color primaryFixedDim = Color(0xFF638EFF);
  static const Color primaryFixed = Color(0xFF799DFF);
  
  static const Color secondary = Color(0xFF006B15); // Pitch Green / Field turf
  static const Color secondaryDim = Color(0xFF005D11);
  static const Color secondaryContainer = Color(0xFF00FC40); // Neon Green accent
  static const Color secondaryFixed = Color(0xFF00FC40);
  static const Color secondaryFixedDim = Color(0xFF00EC3B);
  
  static const Color tertiary = Color(0xFFA33800); // Orange alert / Flash sales
  static const Color tertiaryContainer = Color(0xFFFF956B);
  static const Color tertiaryDim = Color(0xFF8F3000);
  static const Color tertiaryFixed = Color(0xFFFF956B);
  static const Color tertiaryFixedDim = Color(0xFFFF7E49);
  
  // Tonal Layering
  static const Color background = Color(0xFFDEFFE1); // Mint-white (Level 0)
  static const Color surface = Color(0xFFDEFFE1);
  static const Color surfaceBright = Color(0xFFDEFFE1);
  static const Color surfaceContainerLow = Color(0xFFCBFDD3); // Level 1 (Sections)
  static const Color surfaceContainer = Color(0xFFBFF5C8);
  static const Color surfaceContainerHigh = Color(0xFFB6F0C1);
  static const Color surfaceContainerHighest = Color(0xFFADEBBA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Level 2 (Cards)
  static const Color surfaceVariant = Color(0xFFADEBBA);
  static const Color surfaceDim = Color(0xFFA1E4B0);
  
  static const Color onBackground = Color(0xFF0D361C); // Deep dark green instead of black
  static const Color onSurface = Color(0xFF0D361C);
  static const Color onSurfaceVariant = Color(0xFF3C6446);
  
  static const Color onPrimary = Color(0xFFF1F2FF);
  static const Color onPrimaryContainer = Color(0xFF001E58);
  static const Color onPrimaryFixed = Color(0xFF000000);
  static const Color onPrimaryFixedVariant = Color(0xFF00276C);

  static const Color onSecondary = Color(0xFFD1FFC6);
  static const Color onSecondaryContainer = Color(0xFF005A10);
  static const Color onSecondaryFixed = Color(0xFF00440A);
  static const Color onSecondaryFixedVariant = Color(0xFF006513);

  static const Color onTertiary = Color(0xFFFFEFEB);
  static const Color onTertiaryContainer = Color(0xFF5B1B00);
  static const Color onTertiaryFixed = Color(0xFF310B00);
  static const Color onTertiaryFixedVariant = Color(0xFF692100);
  
  static const Color outline = Color(0xFF578060);
  static const Color outlineVariant = Color(0xFF8CB794);
  
  static const Color error = Color(0xFFB02500);
  static const Color errorContainer = Color(0xFFF95630);
  static const Color errorDim = Color(0xFFB92902);
  static const Color onError = Color(0xFFFFEFEB);
  static const Color onErrorContainer = Color(0xFF520C00);

  static const Color inverseSurface = Color(0xFF001205);
  static const Color inverseOnSurface = Color(0xFF7CA784);
  static const Color inversePrimary = Color(0xFF5E8BFF);
  static const Color surfaceTint = Color(0xFF0052D0);

  // Deep Green Ambient Glow Shadow
  static List<BoxShadow> get ambientGlow => [
    const BoxShadow(
      color: Color(0x140D361C), // 0.08 opacity deep green
      blurRadius: 40,
      offset: Offset(0, 20),
    ),
  ];
}
