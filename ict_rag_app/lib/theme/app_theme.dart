import 'package:flutter/material.dart';
import '../models/models.dart';

class AppColors {
  static AppThemeMode _mode = AppThemeMode.dark;

  static void setThemeMode(AppThemeMode mode) => _mode = mode;
  static AppThemeMode get themeMode => _mode;
  static bool get isDark => _mode == AppThemeMode.dark || _mode == AppThemeMode.oled;
  static bool get isOled => _mode == AppThemeMode.oled;

  static Color get background {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFFF5F7FA);
      case AppThemeMode.dark: return const Color(0xFF0A0E21);
      case AppThemeMode.oled: return const Color(0xFF000000);
    }
  }

  static Color get surface {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFFFFFFFF);
      case AppThemeMode.dark: return const Color(0xFF111730);
      case AppThemeMode.oled: return const Color(0xFF0A0A0A);
    }
  }

  static Color get surfaceLight {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFFEEF1F6);
      case AppThemeMode.dark: return const Color(0xFF1A2040);
      case AppThemeMode.oled: return const Color(0xFF141414);
    }
  }

  static Color get card {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFFFFFFFF);
      case AppThemeMode.dark: return const Color(0xFF151B33);
      case AppThemeMode.oled: return const Color(0xFF0D0D0D);
    }
  }

  static Color get cardBorder {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFFE0E4EC);
      case AppThemeMode.dark: return const Color(0xFF1E2745);
      case AppThemeMode.oled: return const Color(0xFF1A1A1A);
    }
  }

  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF8B83FF);
  static const accent = Color(0xFF00D4AA);
  static const accentPink = Color(0xFFFF6B9D);
  static const accentBlue = Color(0xFF4FC3F7);

  static Color get textPrimary {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFF1A1D2E);
      case AppThemeMode.dark: return const Color(0xFFFFFFFF);
      case AppThemeMode.oled: return const Color(0xFFFFFFFF);
    }
  }

  static Color get textSecondary {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFF5A6380);
      case AppThemeMode.dark: return const Color(0xFF8892B0);
      case AppThemeMode.oled: return const Color(0xFFA0A8C0);
    }
  }

  static Color get textMuted {
    switch (_mode) {
      case AppThemeMode.light: return const Color(0xFF9CA3B8);
      case AppThemeMode.dark: return const Color(0xFF5A6380);
      case AppThemeMode.oled: return const Color(0xFF707888);
    }
  }

  static const success = Color(0xFF00E676);
  static const error = Color(0xFFFF5252);
  static const warning = Color(0xFFFFAB40);
  static const gradientStart = Color(0xFF6C63FF);
  static const gradientEnd = Color(0xFF00D4AA);
  static const gradientPink = Color(0xFFFF6B9D);
  static const gradientBlue = Color(0xFF4FC3F7);
}

class AppGradients {
  static const primary = LinearGradient(
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const pinkBlue = LinearGradient(
    colors: [AppColors.gradientPink, AppColors.gradientBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get card => LinearGradient(
    colors: AppColors.isOled
        ? [const Color(0xFF0D0D0D), const Color(0xFF0A0A0A)]
        : [const Color(0xFF1A2040), const Color(0xFF111730)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData appTheme({
  AppThemeMode mode = AppThemeMode.dark,
  TargetPlatform platform = TargetPlatform.android,
}) {
  AppColors.setThemeMode(mode);
  final isDark = mode != AppThemeMode.light;
  final isIOS = platform == TargetPlatform.iOS;

  // M3 Expressive: larger radii, bolder shapes for Android
  // Liquid Glass: translucent surfaces, thinner borders for iOS
  final cardRadius = isIOS ? 20.0 : 16.0;
  final buttonRadius = isIOS ? 14.0 : 12.0;
  final inputRadius = isIOS ? 14.0 : 12.0;

  return ThemeData(
    platform: platform,
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface,
    ),
    splashFactory: isIOS ? NoSplash.splashFactory : InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: isIOS
          ? AppColors.background.withValues(alpha: 0.85)
          : AppColors.background,
      elevation: 0,
      scrolledUnderElevation: isIOS ? 0 : 2,
      centerTitle: isIOS,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: isIOS
          ? AppColors.card.withValues(alpha: 0.9)
          : AppColors.card,
      elevation: isIOS ? 0 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: BorderSide(
          color: isIOS
              ? AppColors.cardBorder.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: isIOS ? 0.5 : 1,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isIOS
          ? AppColors.surface.withValues(alpha: 0.85)
          : AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      hintStyle: TextStyle(color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isIOS ? 18 : 16),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: const PredictiveBackPageTransitionsBuilder(),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      },
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      bodySmall: TextStyle(color: AppColors.textMuted),
    ),
  );
}
