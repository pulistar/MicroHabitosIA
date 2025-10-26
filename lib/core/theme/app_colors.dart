import 'package:flutter/material.dart';

class AppColors {
  // Colores principales del gradiente púrpura-rosado
  static const Color darkPurple = Color(0xFF1a0033);
  static const Color mediumPurple = Color(0xFF2d0052);
  static const Color purple = Color(0xFF4a0080);
  static const Color purplePink = Color(0xFF6b2d8f);
  static const Color lightPurple = Color(0xFF8b3a9e);

  // Colores secundarios
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);

  // Colores de acento
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentGreen = Color(0xFF26C281);
  static const Color accentBlue = Color(0xFF3498DB);
  static const Color accentYellow = Color(0xFFF1C40F);
  
  // Colores del podio
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color bronze = Color(0xFFCD7F32);

  // Colores de estado
  static const Color success = Color(0xFF26C281);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Colores de fondo
  static const Color background = darkPurple;
  static const Color surface = mediumPurple;

  // Gradientes
  static const List<Color> primaryGradient = [
    darkPurple,
    mediumPurple,
    purple,
    purplePink,
    lightPurple,
  ];

  static const List<double> primaryGradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
}
