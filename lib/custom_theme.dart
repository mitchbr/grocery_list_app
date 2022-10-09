import 'package:flutter/material.dart';

class CustomTheme {
  var primaryColor = const Color(0xFF2b2b2b);
  var secondaryColor = const Color(0xFF141414);

  var accentHighlightColor = const Color(0xFF93b564);
  var accentColor = const Color(0xFF536638);

  var textColor = Colors.white;

  ThemeData customTheme() {
    return ThemeData(
      colorScheme: const ColorScheme.dark(),
      primaryColor: primaryColor,
      backgroundColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      appBarTheme: AppBarTheme(
        color: secondaryColor,
      ),
      buttonTheme: ButtonThemeData(buttonColor: accentColor),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: secondaryColor,
        unselectedItemColor: accentColor,
        selectedItemColor: accentHighlightColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(16.0),
          primary: textColor,
          textStyle: const TextStyle(fontSize: 20),
          backgroundColor: accentColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: accentColor),
        ),
      ),
      fontFamily: 'Georgia',
    );
  }
}