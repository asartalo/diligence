import 'package:flutter/material.dart';

import '../utils/detect.dart';
import './colors.dart' as colors;

class DiligenceTextTheme {
  final TextTheme textTheme;

  DiligenceTextTheme({required this.textTheme});

  TextStyle get dataTitle {
    return textTheme.bodyLarge!.copyWith(
      color: colors.grayText,
      letterSpacing: 1,
    );
  }
}

class DiligenceLengths {
  final double space = 20;
}

class DiligenceTheme {
  final ThemeData themeData;
  final DiligenceLengths lengths = DiligenceLengths();
  final DiligenceTextTheme text;
  static Map<ThemeData, DiligenceTheme> themeCache = {};

  DiligenceTheme({
    required this.themeData,
    required this.text,
  });

  factory DiligenceTheme.fromTheme(ThemeData themeData) {
    DiligenceTheme? theTheme = themeCache[themeData];
    if (theTheme == null) {
      themeCache.clear();
      theTheme = DiligenceTheme(
        themeData: themeData,
        text: DiligenceTextTheme(textTheme: themeData.textTheme),
      );
      themeCache[themeData] = theTheme;
    }
    return theTheme;
  }

  TextTheme get textTheme {
    return themeData.textTheme;
  }

  static ThemeData createThemeData() {
    final backgroundColor = colors.paperGray;
    final visualDensity = isDesktop()
        ? const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity) // VisualDensity.compact
        : VisualDensity.standard;

    return ThemeData(
      useMaterial3: true,
      primaryColor: colors.primaryColor,
      cardColor: Colors.white,
      visualDensity: visualDensity,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16.0,
        ),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w300,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
      ).apply(
        displayColor: colors.black,
      ),
      cardTheme: const CardTheme(
        elevation: 0,
      ),
      colorScheme:
          ColorScheme.fromSwatch(primarySwatch: colors.twilightBlue).copyWith(
        secondary: colors.secondaryColor,
        background: backgroundColor,
      ),
      dialogBackgroundColor: Colors.white,
    );
  }
}
