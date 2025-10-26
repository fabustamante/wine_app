import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  static const _kDarkModeKey = 'isDarkMode';
  static const _kSelectedColorKey = 'selectedColor';

  final SharedPreferences _prefs;
  AppTheme _theme;

  // Constructor "preloaded": ya viene con prefs y valores iniciales
  ThemeController.preloaded(
    this._prefs, {
    required bool isDarkMode,
    required int selectedColor,
  }) : _theme = AppTheme(
          isDarkMode: isDarkMode,
          selectedColor: selectedColor.clamp(0, primaryColors.length - 1),
        );

  ThemeData get themeData => _theme.getTheme();
  bool get isDarkMode => _theme.isDarkMode;
  int get selectedColor => _theme.selectedColor;

  Future<void> toggleDarkMode(bool value) async {
    _theme = AppTheme(
      selectedColor: _theme.selectedColor,
      isDarkMode: value,
    );
    await _prefs.setBool(_kDarkModeKey, value);
    notifyListeners();
  }

  Future<void> changeColor(int index) async {
    final safeIndex = index.clamp(0, primaryColors.length - 1);
    _theme = AppTheme(
      selectedColor: safeIndex,
      isDarkMode: _theme.isDarkMode,
    );
    await _prefs.setInt(_kSelectedColorKey, safeIndex);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _theme = AppTheme();
    await _prefs.setBool(_kDarkModeKey, _theme.isDarkMode);
    await _prefs.setInt(_kSelectedColorKey, _theme.selectedColor);
    notifyListeners();
  }
}
