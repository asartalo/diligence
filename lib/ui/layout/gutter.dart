import 'package:flutter/material.dart';

List<Widget> withGutter(List<Widget> widgets, double size) {
  final List<Widget> output = [];

  for (var i = 0; i < widgets.length; i++) {
    output.add(widgets[i]);
    if (i + 1 < widgets.length) {
      output.add(SizedBox(
        width: size,
        height: size,
      ));
    }
  }

  return output;
}
