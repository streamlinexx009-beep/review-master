import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A73E8),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,

      fontFamily:
          AppTypography.fontFamily,

      colorScheme: scheme,

      scaffoldBackgroundColor:
          const Color(0xFFF8F9FA),

      appBarTheme: const AppBarTheme(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),

      navigationRailTheme:
          NavigationRailThemeData(
        backgroundColor:
            Colors.white,
        indicatorColor:
            scheme.primaryContainer,
        selectedIconTheme:
            IconThemeData(
          color: scheme.primary,
        ),
        selectedLabelTextStyle:
            TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor:
            Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20),
          side: BorderSide(
            color:
                Colors.grey.shade200,
          ),
        ),
      ),

      inputDecorationTheme:
          InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide(
            color:
                Colors.grey.shade300,
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
      ),

      elevatedButtonTheme:
          ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize:
              const Size(
            double.infinity,
            52,
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),
        ),
      ),

      textTheme: Typography
          .material2021()
          .black
          .copyWith(
            headlineLarge:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
            headlineMedium:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
            headlineSmall:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
            titleLarge:
                const TextStyle(
              fontWeight:
                  FontWeight.w600,
            ),
          ),
    );
  }
}