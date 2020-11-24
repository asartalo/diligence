import 'dart:ui';

import 'package:flutter/material.dart';

import './colors.dart';

var diligenceColors = DiligenceColors();

class DiligenceTextTheme {
  final TextTheme textTheme;

  DiligenceTextTheme({this.textTheme});

  TextStyle get dataTitle {
    return textTheme.headline6;
  }
}

class DiligenceTheme {
  final ThemeData themeData;
  final colors = DiligenceColors;
  final DiligenceTextTheme text;

  DiligenceTheme({this.themeData, this.text});

  static DiligenceTheme fromTheme(ThemeData themeData) {
    return DiligenceTheme(
      themeData: themeData,
      text: DiligenceTextTheme(textTheme: themeData.textTheme),
    );
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
