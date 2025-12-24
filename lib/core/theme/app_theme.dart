import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sage500,
        primary: AppColors.sage500,
        secondary: AppColors.clay500,
        surface: AppColors.sand50,
        onSurface: AppColors.midnight900,
        surfaceContainerLow: AppColors.sage50,
      ),
      scaffoldBackgroundColor: AppColors.sand50,
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: AppColors.midnight900,
        displayColor: AppColors.midnight900,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sand50,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.sage100),
        ),
      ),
    );
  }
}
