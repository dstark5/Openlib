// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:openlib/ui/extensions.dart';

final secondaryColor = '#FB0101'.toColor();

ThemeData lightTheme = ThemeData(
  primaryColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Colors.white,
    secondary: secondaryColor,
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
    selectionColor: secondaryColor,
    selectionHandleColor: secondaryColor,
  ),
);

ThemeData darkTheme = ThemeData(
  primaryColor: Colors.black,
  scaffoldBackgroundColor: Colors.black,
  colorScheme: ColorScheme.dark(
    primary: Colors.black,
    secondary: secondaryColor,
    tertiary: Colors.white,
    tertiaryContainer: '#141414'.toColor(),
    surface: Colors.black,
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
    selectionColor: secondaryColor,
    selectionHandleColor: secondaryColor,
  ),
);
