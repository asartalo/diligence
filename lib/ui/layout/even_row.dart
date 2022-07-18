import 'package:flutter/material.dart';
import 'gutter.dart';

/// Row with evenly spaced items
class EvenRow extends StatelessWidget {
  final List<Widget> children;
  final double gutter;

  const EvenRow({
    required this.children,
    this.gutter = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: gutter == 0.0
          ? _expandedChildren()
          : withGutter(_expandedChildren(), gutter),
    );
  }

  List<Widget> _expandedChildren() {
    return children.map((child) => Expanded(child: child)).toList();
  }
}
