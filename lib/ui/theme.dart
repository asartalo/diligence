import 'package:flutter/material.dart';

import './colors.dart' as DiligenceColors;

var diligenceTheme = ThemeData(
  // This is the theme of your application.
  //
  // Try running your application with "flutter run". You'll see the
  // application has a blue toolbar. Then, without quitting the app, try
  // changing the primarySwatch below to Colors.green and then invoke
  // "hot reload" (press "r" in the console where you ran "flutter run",
  // or simply save your changes to "hot reload" in a Flutter IDE).
  // Notice that the counter didn't reset back to zero; the application
  // is not restarted.
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
  ),
);
