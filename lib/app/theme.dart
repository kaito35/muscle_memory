import 'package:flutter/material.dart';

const ink = Color(0xFF233329);
const olive = Color(0xFF526642);
const canvas = Color(0xFFF5F5EF);
const lime = Color(0xFFE4EEC5);

ThemeData bodymakeTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: olive, surface: canvas);
  return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: ink,
              height: 1.3),
          headlineMedium:
              TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ink),
          titleLarge:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
          titleMedium:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink),
          bodyLarge: TextStyle(fontSize: 15, height: 1.7, color: ink),
          bodyMedium: TextStyle(fontSize: 13, height: 1.6, color: ink)),
      appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          centerTitle: false,
          scrolledUnderElevation: 0),
      cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFFE5E7DD)))),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)))),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDCDFD4))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDCDFD4)))),
      navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white, indicatorColor: lime, height: 76),
      dividerTheme: const DividerThemeData(color: Color(0xFFE5E7DD)));
}
