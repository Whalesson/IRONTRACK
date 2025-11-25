import 'package:flutter/material.dart';

class AppColors {
  // Cores Neon Principais
  static const Color neonPrimary = Color(0xFF00FF41); // Verde neon
  static const Color neonSecondary = Color(0xFF00D9FF); // Ciano neon
  static const Color neonAccent = Color(0xFFFF006E); // Magenta neon

  // Cores de Superfície
  static const Color background = Color(0xFF0A0A0A); // Preto profundo
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceMedium = Color(0xFF2A2A2A);
  static const Color surfaceLight = Color(0xFF3A3A3A);

  // Cores de Estado
  static const Color success = Color(0xFF00FF41); // Verde neon
  static const Color error = Color(0xFFFF006E); // Magenta neon
  static const Color warning = Color(0xFFFFD700); // Ouro

  // Cores de Gamificação
  static const Color xpYellow = Color(0xFFFFD700); // Ouro
  static const Color prGold = Color(0xFFFFA500); // Laranja ouro
  static const Color levelPurple = Color(0xFF9D00FF); // Roxo neon
  static const Color bossRed = Color(0xFFFF0000); // Vermelho puro

  // Cores de Texto
  static const Color textPrimary = Color(0xFFFFFFFF); // Branco
  static const Color textSecondary = Color(0xFFB0B0B0); // Cinza claro
  static const Color textDisabled = Color(0xFF666666); // Cinza escuro

  // Cores de Borda
  static const Color borderPrimary = neonPrimary;
  static const Color borderSecondary = surfaceMedium;
  static const Color borderAccent = neonAccent;
}
