import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wine_app/core/theme/app_theme.dart';

// Provider que expondrá SharedPreferences ya inicializado en main.dart
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

class ThemeNotifier extends Notifier<AppTheme> {
  late final SharedPreferences _prefs;

  @override
  AppTheme build() {
    _prefs = ref.read(sharedPrefsProvider);
    return AppTheme(
      selectedColor: _prefs.getInt('selectedColor') ?? 0,
      isDarkMode: _prefs.getBool('isDarkMode') ?? false,
    );
  }

  void toggleDarkMode([bool? value]) {
    final newVal = value ?? !state.isDarkMode;
    state = AppTheme(selectedColor: state.selectedColor, isDarkMode: newVal);
    _prefs.setBool('isDarkMode', newVal);
  }

  void changeColor(int index) {
    state = AppTheme(selectedColor: index, isDarkMode: state.isDarkMode);
    _prefs.setInt('selectedColor', index);
  }

  void resetToDefaults() {
    state = AppTheme();
    _prefs.setBool('isDarkMode', state.isDarkMode);
    _prefs.setInt('selectedColor', state.selectedColor);
  }
}

final themeNotifierProvider = NotifierProvider<ThemeNotifier, AppTheme>(ThemeNotifier.new);
