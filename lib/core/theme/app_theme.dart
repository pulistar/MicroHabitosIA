import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color primario
      primaryColor: AppColors.purple,
      scaffoldBackgroundColor: AppColors.background,
      
      // Colores
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        secondary: AppColors.accentPink,
        tertiary: AppColors.accentOrange,
        surface: AppColors.surface,
        error: AppColors.error,
        background: AppColors.background,
      ),

      // Tipografía
      textTheme: TextTheme(
        displayLarge: AppTypography.headlineLarge,
        displayMedium: AppTypography.headlineMedium,
        displaySmall: AppTypography.headlineSmall,
        headlineLarge: AppTypography.titleLarge,
        headlineMedium: AppTypography.titleMedium,
        headlineSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          side: const BorderSide(color: AppColors.white, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: AppTypography.titleMedium,
        ),
      ),

      // Botones de texto
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.white,
          textStyle: AppTypography.titleMedium,
        ),
      ),

      // Botones flotantes
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.purple,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purplePink),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purplePink, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: AppTypography.bodyMedium,
        labelStyle: AppTypography.titleSmall,
      ),

      // Diálogos
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: AppTypography.headlineSmall,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.white30,
        thickness: 1,
        space: 16,
      ),
    );
  }
}
