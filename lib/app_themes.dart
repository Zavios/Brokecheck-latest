// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppThemes {
  // Light theme colors
  static const Color _lightPrimaryColor = Color(0xFF4CAF50);
  static const Color _lightAccentColor = Color(0xFF8BC34A);
  static const Color _lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color _lightCardColor = Colors.white;
  static const Color _lightTextColor = Color(0xFF333333);
  static const Color _lightSecondaryTextColor = Color(0xFF757575);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF2E7D32);
  static const Color _darkAccentColor = Color(0xFF558B2F);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);
  static const Color _darkTextColor = Colors.white;
  static const Color _darkSecondaryTextColor = Color(0xFFBDBDBD);
  static const Color _lightErrorColor = Color(0xFFD32F2F); // Red 700
  static const Color _darkErrorColor = Color(0xFFEF5350); // Red 400

  static Color getErrorColor(bool isDarkMode) {
    return isDarkMode ? _darkErrorColor : _lightErrorColor;
  }

  // Common gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Action button gradients
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightAccentColor,
      surface: _lightBackgroundColor,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'poppy',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: _lightCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _lightPrimaryColor
              : Colors.grey),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? _lightPrimaryColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _lightTextColor,
        fontFamily: 'poppy',
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _lightTextColor,
        fontFamily: 'poppy',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: _lightTextColor,
        fontFamily: 'quickie',
      ),
      bodyMedium: TextStyle(
        color: _lightTextColor,
        fontFamily: 'quickie',
      ),
      labelMedium: TextStyle(
        color: _lightSecondaryTextColor,
        fontFamily: 'quickie',
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _lightPrimaryColor),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'quickie'),
      labelStyle: const TextStyle(
          color: _lightSecondaryTextColor, fontFamily: 'quickie'),
    ),
    fontFamily: 'quickie',
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      background: _darkBackgroundColor,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'poppy',
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: _darkCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkAccentColor,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? _darkPrimaryColor
              : Colors.grey),
      trackColor: MaterialStateProperty.resolveWith((states) =>
          states.contains(MaterialState.selected)
              ? _darkPrimaryColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.5)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkCardColor,
      selectedItemColor: _darkAccentColor,
      unselectedItemColor: Colors.grey,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: _darkTextColor,
        fontFamily: 'poppy',
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: _darkTextColor,
        fontFamily: 'poppy',
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: _darkTextColor,
        fontFamily: 'quickie',
      ),
      bodyMedium: TextStyle(
        color: _darkTextColor,
        fontFamily: 'quickie',
      ),
      labelMedium: TextStyle(
        color: _darkSecondaryTextColor,
        fontFamily: 'quickie',
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[800],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _darkAccentColor),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'quickie'),
      labelStyle: const TextStyle(
          color: _darkSecondaryTextColor, fontFamily: 'quickie'),
    ),
    fontFamily: 'quickie',
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242),
      thickness: 1,
    ),
  );

  // Helper methods
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? _darkBackgroundColor : _lightBackgroundColor;
  }

  static Color getCardColor(bool isDarkMode) {
    return isDarkMode ? _darkCardColor : _lightCardColor;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? _darkTextColor : _lightTextColor;
  }

  static Color getSecondaryTextColor(bool isDarkMode) {
    return isDarkMode ? _darkSecondaryTextColor : _lightSecondaryTextColor;
  }

  static Color getPrimaryColor(bool isDarkMode) {
    return isDarkMode ? _darkPrimaryColor : _lightPrimaryColor;
  }

  static LinearGradient getPrimaryGradient(bool isDarkMode) {
    return isDarkMode ? darkGradient : primaryGradient;
  }
}
