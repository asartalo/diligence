// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

import '../utils/detect.dart';
import './colors.dart' as colors;

part 'diligence_text_theme.dart';
part 'diligence_lengths.dart';

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
            vertical: VisualDensity.minimumDensity,
          ) // VisualDensity.compact
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
        surface: backgroundColor,
      ),
      dialogBackgroundColor: Colors.white,
    );
  }
}
