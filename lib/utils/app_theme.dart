import 'package:flutter/material.dart';

class AppColors {
  // Pop Kawaii Color Palette
  static const Color primary = Color(0xFFFF69B4);      // Hot Pink
  static const Color secondary = Color(0xFFFFD700);    // Gold/Yellow
  static const Color accent = Color(0xFF00BFFF);       // Deep Sky Blue
  static const Color tertiary = Color(0xFFFF6B6B);     // Coral
  static const Color mint = Color(0xFF98FB98);         // Pale Green
  static const Color lavender = Color(0xFFE6E6FA);     // Lavender
  
  // Background gradients
  static const Color bgStart = Color(0xFFFFF0F5);      // Lavender Blush
  static const Color bgEnd = Color(0xFFE0FFFF);        // Light Cyan
  
  // UI Colors
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  
  // Timing Colors
  static const Color perfect = Color(0xFFFFD700);      // Gold
  static const Color good = Color(0xFF98FB98);         // Green
  static const Color miss = Color(0xFFFF6B6B);         // Red
  
  // Character Colors
  static const Color djGal = Color(0xFFFF69B4);
  static const Color idol = Color(0xFFFFB6C1);
  static const Color denpa = Color(0xFF9370DB);

  static LinearGradient get backgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgStart, bgEnd],
  );

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primary, Color(0xFFFF85C1)],
  );

  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: [secondary, Color(0xFFFFE066)],
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [accent, Color(0xFF66D9FF)],
  );
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 8,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.textLight,
      ),
    ),
  );
}

class KawaiiDecorations {
  static BoxDecoration get starPattern => BoxDecoration(
    gradient: AppColors.backgroundGradient,
  );

  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: borderColor ?? AppColors.primary.withValues(alpha: 0.3),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.2),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static BoxDecoration choiceButtonDecoration({bool isSelected = false}) => BoxDecoration(
    gradient: isSelected ? AppColors.primaryGradient : null,
    color: isSelected ? null : Colors.white,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(
      color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: (isSelected ? AppColors.primary : Colors.black).withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
