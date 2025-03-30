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

MaterialColor createMaterialColorFromRgb(int red, int green, int blue) {
  return createMaterialColor(Color.fromRGBO(red, green, blue, 1));
}

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final Map<int, Color> swatch = {};
  final r = color.r;
  final g = color.g;
  final b = color.b;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.from(
      red: r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      green: g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      blue: b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      alpha: 1.0,
    );
  }

  return MaterialColor(color.toARGB32(), swatch);
}
