import 'package:flutter/material.dart';

MaterialColor createMaterialColorFromRgb(int red, int green, int blue) {
  return createMaterialColor(Color.fromRGBO(red, green, blue, 1));
}

MaterialColor createMaterialColor(Color color) {
  final strengths = <double>[.05];
  final Map<int, Color> swatch = {};
  final r = color.red;
  final g = color.green;
  final b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (final strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }

  return MaterialColor(color.value, swatch);
}
