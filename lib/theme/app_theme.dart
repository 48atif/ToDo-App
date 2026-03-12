import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6C63FF);
  static const accentColor = Color(0xFFFF6584);
  static const dndColor = Color(0xFF1A1A2E);
  static const dndAccent = Color(0xFF6C63FF);

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: CircleBorder(),
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: dndAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: dndColor,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF16213E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: dndAccent,
          foregroundColor: Colors.white,
          elevation: 8,
          shape: CircleBorder(),
        ),
      );
}