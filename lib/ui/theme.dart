import 'dart:ui';

import 'package:flutter/material.dart';

import './colors.dart';

var diligenceColors = DiligenceColors();

class DiligenceTextTheme {
  final TextTheme textTheme;

  DiligenceTextTheme({@required this.textTheme});

  TextStyle get dataTitle {
    return textTheme.headline6;
  }
}

class DiligenceLengths {
  final double space = 20;
}

class DiligenceTheme {
  final ThemeData themeData;
  final colors = DiligenceColors;
  final DiligenceLengths lengths = DiligenceLengths();
  final DiligenceTextTheme text;
  static Map<ThemeData, DiligenceTheme> themeCache = {};

  DiligenceTheme({
    @required this.themeData,
    @required this.text,
  });

  static DiligenceTheme fromTheme(ThemeData themeData) {
    DiligenceTheme theTheme = themeCache[themeData];
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
    return ThemeData(
      primarySwatch: DiligenceColors.blue,
      accentColor: DiligenceColors.orangeDawn,
      backgroundColor: DiligenceColors.paperGray,
      cardColor: Colors.white,
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        bodyText1: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 16.0,
        ),
        headline2: TextStyle(
          fontWeight: FontWeight.w300,
        ),
      ).apply(
        displayColor: DiligenceColors.black,
      ),
    );
  }
}
