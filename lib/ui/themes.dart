import 'package:flutter/material.dart';
import 'package:openlib/ui/extensions.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  primaryColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Colors.white,
    secondary: '#FB0101'.toColor(),
    tertiary: Colors.black,
    tertiaryContainer: '#F2F2F2'.toColor(),
  ),
  textTheme: TextTheme(
      displayLarge: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 21,
      ),
      displayMedium: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        overflow: TextOverflow.ellipsis,
      ),
      headlineMedium: TextStyle(
        color: "#595E60".toColor(),
      ),
      headlineSmall: TextStyle(
        color: "#7F7F7F".toColor(),
      )),
  fontFamily: GoogleFonts.nunito().fontFamily,
  useMaterial3: true,
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: '#FB0101'.toColor(),
    selectionHandleColor: '#FB0101'.toColor(),
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.black,
  colorScheme: ColorScheme.dark(
    primary: Colors.black,
    secondary: '#FB0101'.toColor(),
    tertiary: Colors.white,
    tertiaryContainer: '#2B2B2B'.toColor(),
  ),
  textTheme: TextTheme(
    displayLarge: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 21,
    ),
    displayMedium: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      overflow: TextOverflow.ellipsis,
    ),
    headlineMedium: TextStyle(
      color: "#F5F5F5".toColor(),
    ),
    headlineSmall: TextStyle(
      color: "#E8E2E2".toColor(),
    ),
  ),
  fontFamily: GoogleFonts.nunito().fontFamily,
  useMaterial3: true,
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: '#FB0101'.toColor(),
    selectionHandleColor: '#FB0101'.toColor(),
  ),
);
