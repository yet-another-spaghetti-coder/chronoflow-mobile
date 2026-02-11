import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  static const Color darkGreenPrimary = Color(0xFF06402b);
  static const Color darkGreenSecondary = Color(0xFF00573f);

  static const Color darkBackground = Color(0xFF0a0a0a);
  static const Color darkSurface = Color(0xFF141414);

  static ThemeData get materialLightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: darkGreenSecondary,
      onPrimary: Colors.white,
      secondary: darkGreenPrimary,
      onSecondary: Colors.white,
      surface: Colors.white,
      error: Colors.redAccent,
      onSurface: Color(0xFF1a1a1a),
    ),
    scaffoldBackgroundColor: const Color(0xFFfafafa),
    appBarTheme: AppBarTheme(
      backgroundColor: darkGreenPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ubuntuSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkGreenPrimary.withValues(alpha: 0.1)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkGreenSecondary,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.ubuntuSansTextTheme(ThemeData.light().textTheme),
  );

  static ThemeData get materialDarkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: darkGreenSecondary,
      onPrimary: Colors.white,
      secondary: darkGreenPrimary,
      onSecondary: Colors.white,
      surface: darkSurface,
      error: Colors.redAccent,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: darkGreenPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.ubuntuSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: darkGreenSecondary.withValues(alpha: 0.3)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: darkGreenSecondary,
      unselectedItemColor: Colors.grey,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: darkGreenSecondary,
      foregroundColor: Colors.white,
    ),
    textTheme: GoogleFonts.ubuntuSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );

  static CupertinoThemeData get cupertinoLightTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: darkGreenSecondary,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: darkGreenPrimary,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.label,
        navTitleTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        navLargeTitleTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkGreenPrimary,
        ),
        actionTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 17,
          color: darkGreenSecondary,
        ),
        tabLabelTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static CupertinoThemeData get cupertinoDarkTheme {
    return CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: darkGreenSecondary,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: CupertinoColors.black,
      barBackgroundColor: darkGreenPrimary,
      textTheme: CupertinoTextThemeData(
        primaryColor: CupertinoColors.white,
        navTitleTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        navLargeTitleTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkGreenSecondary,
        ),
        actionTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 17,
          color: darkGreenSecondary,
        ),
        tabLabelTextStyle: GoogleFonts.ubuntuSans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
