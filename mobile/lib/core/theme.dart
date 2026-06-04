/// Echo — App Theme
///
/// Premium dark theme with purple-blue gradient accents,
/// glassmorphism cards, and Google Fonts typography.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ───────────────────────────────────────────────────────────

class EchoColors {
  // Backgrounds
  static const Color background = Color(0xFF0A0A1A);
  static const Color surface = Color(0xFF12122A);
  static const Color surfaceLight = Color(0xFF1A1A3E);
  static const Color card = Color(0xFF16163A);

  // Accents
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF4ECDC4);
  static const Color accent = Color(0xFF7B6FFF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9B59FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0x1A6C63FF), Color(0x0A4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Text
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFA0A0C0);
  static const Color textMuted = Color(0xFF6060A0);

  // Status
  static const Color success = Color(0xFF4ECDC4);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF6C63FF);

  // Misc
  static const Color divider = Color(0xFF2A2A50);
  static const Color shimmer = Color(0xFF2A2A50);
}

// ─── Theme Data ──────────────────────────────────────────────────────────────

class EchoTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EchoColors.background,
      primaryColor: EchoColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: EchoColors.primary,
        secondary: EchoColors.secondary,
        surface: EchoColors.surface,
        error: EchoColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: EchoColors.textPrimary,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: EchoColors.textPrimary),
      ),

      // Text
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: EchoColors.textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: EchoColors.textPrimary,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: EchoColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: EchoColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: EchoColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: EchoColors.textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EchoColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EchoColors.divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EchoColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: EchoColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: EchoColors.textMuted,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: EchoColors.textSecondary,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EchoColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EchoColors.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: EchoColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: CircleBorder(),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: EchoColors.surface,
        selectedItemColor: EchoColors.primary,
        unselectedItemColor: EchoColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Card
      cardTheme: CardThemeData(
        color: EchoColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: EchoColors.divider, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: EchoColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: EchoColors.textPrimary,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EchoColors.surfaceLight,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: EchoColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: EchoColors.divider,
        thickness: 0.5,
      ),
    );
  }
}

// ─── Decorations ─────────────────────────────────────────────────────────────

class EchoDecorations {
  /// Glassmorphism card decoration
  static BoxDecoration glassCard({
    double borderRadius = 20,
    double opacity = 0.08,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.white.withValues(alpha: opacity),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 0.5,
      ),
    );
  }

  /// Gradient card decoration
  static BoxDecoration gradientCard({double borderRadius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: EchoColors.cardGradient,
      border: Border.all(
        color: EchoColors.primary.withValues(alpha: 0.2),
        width: 0.5,
      ),
    );
  }

  /// Primary gradient button decoration
  static BoxDecoration gradientButton({double borderRadius = 16}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: EchoColors.primaryGradient,
      boxShadow: [
        BoxShadow(
          color: EchoColors.primary.withValues(alpha: 0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
