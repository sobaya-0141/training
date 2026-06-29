import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFFE35B32);
  static const _lightScaffold = Color(0xFFF7F4EF);

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: _lightScaffold,
      useMaterial3: true,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.white,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
