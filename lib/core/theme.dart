import 'package:flutter/material.dart';

class AppTheme {
  // ── Electric Wave Palette ──────────────────────────────────────────────────
  static const Color primary       = Color(0xFF0052FF); // biru tua Electric Wave
  static const Color primaryLight  = Color(0xFF00F0FF); // cyan Electric Wave
  static const Color background    = Color(0xFF020B1E); // dark navy
  static const Color surface       = Color(0xFF0A1A35); // sedikit lebih terang
  static const Color card          = Color(0xFF0D2040); // card dark navy
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BBFDE); // biru muda soft
  static const Color gold          = Color(0xFF00F0FF); // accent cyan

  // Gradient Electric Wave
  static const LinearGradient electricWaveGradient = LinearGradient(
    colors: [Color(0xFF0052FF), Color(0xFF00F0FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: primaryLight,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF0F5FF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFFEEF4FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displaySmall:   TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      titleLarge:     TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      titleMedium:    TextStyle(color: Colors.black),
      bodyLarge:      TextStyle(color: Colors.black),
      bodyMedium:     TextStyle(color: Colors.grey),
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: primaryLight,
      surface: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryLight, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
    ),
    textTheme: const TextTheme(
      displaySmall:   TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      titleLarge:     TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium:    TextStyle(color: textPrimary),
      bodyLarge:      TextStyle(color: textPrimary),
      bodyMedium:     TextStyle(color: textSecondary),
    ),
  );
}