import 'package:flutter/material.dart';

/// Row with evenly spaced items
class EvenRow extends StatelessWidget {
  final List<Widget> children;

  EvenRow({@required this.children});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children
          .map(
            (child) => Expanded(child: child),
          )
          .toList(),
    );
  }
}
