// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  static const String THEME_KEY = "theme_key";

  // Constructor loads saved theme
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Getter for current theme mode
  bool get isDarkMode => _isDarkMode;

  // Getter for current theme mode as ThemeMode
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // Toggle theme and save preference
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // Set specific theme
  void setDarkMode(bool isDark) {
    _isDarkMode = isDark;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // Load theme from shared preferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(THEME_KEY) ?? false;
    notifyListeners();
  }

  // Save theme to shared preferences
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(THEME_KEY, _isDarkMode);
  }
}
