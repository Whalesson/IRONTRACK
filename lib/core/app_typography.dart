import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Fonte Pixel Art para títulos e elementos principais
  static TextStyle pixelTitle({Color color = AppColors.neonPrimary, double fontSize = 24}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
      letterSpacing: 2,
    );
  }

  static TextStyle pixelSubtitle({Color color = AppColors.textPrimary, double fontSize = 14}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
      letterSpacing: 1,
    );
  }

  static TextStyle pixelBody({Color color = AppColors.textPrimary, double fontSize = 12}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
    );
  }

  static TextStyle pixelCaption({Color color = AppColors.textSecondary, double fontSize = 10}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
    );
  }

  // Fonte normal para textos longos (mais legível)
  static TextStyle normalTitle({Color color = AppColors.neonPrimary, double fontSize = 24}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    );
  }

  static TextStyle normalSubtitle({Color color = AppColors.textPrimary, double fontSize = 16}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    );
  }

  static TextStyle normalBody({Color color = AppColors.textPrimary, double fontSize = 14}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
    );
  }

  static TextStyle normalCaption({Color color = AppColors.textSecondary, double fontSize = 12}) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
    );
  }

  // Estilos especiais
  static TextStyle statValue({Color color = AppColors.neonPrimary, double fontSize = 32}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle statLabel({Color color = AppColors.textSecondary, double fontSize = 10}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
      letterSpacing: 1.5,
    );
  }

  static TextStyle buttonText({Color color = AppColors.background, double fontSize = 14}) {
    return GoogleFonts.pressStart2p(
      color: color,
      fontSize: fontSize,
      letterSpacing: 1.2,
    );
  }

  static TextStyle prText({double fontSize = 14}) {
    return GoogleFonts.pressStart2p(
      color: AppColors.prGold,
      fontSize: fontSize,
      letterSpacing: 1.2,
    );
  }

  static TextStyle levelText({double fontSize = 14}) {
    return GoogleFonts.pressStart2p(
      color: AppColors.levelPurple,
      fontSize: fontSize,
      letterSpacing: 1.2,
    );
  }
}
