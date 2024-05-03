import 'package:flutter/widgets.dart';

typedef Builder<T> = Widget Function(T element);

List<Widget> joinWidgets<T>(
  List<T> elements, {
  required Widget delimeter,
  required Builder<T> builder,
}) {
  final widgets = <Widget>[];
  for (var i = 0; i < elements.length; i++) {
    if (i > 0) widgets.add(delimeter);
    widgets.add(builder(elements[i]));
  }

  return widgets;
}
