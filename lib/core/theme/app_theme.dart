import 'package:flutter/material.dart';

final List<MaterialColor> primaryColors = Colors.primaries;

class AppTheme {
  final int selectedColor;
  final bool isDarkMode;

  AppTheme({
    this.selectedColor = 0,
    this.isDarkMode = false,
  });

  ThemeData getTheme() {
    return ThemeData(
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: primaryColors[selectedColor]
    );
  }
}