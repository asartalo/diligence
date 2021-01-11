import 'package:flutter/material.dart';

class EasyCard extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment align;
  final double padding;

  const EasyCard({
    @required this.children,
    this.align = alignCenter,
    this.padding = 20.0,
  });

  static const alignLeft = CrossAxisAlignment.start;
  static const alignCenter = CrossAxisAlignment.center;
  static const alignRight = CrossAxisAlignment.end;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: align,
          children: children,
        ),
      ),
    );
  }
}
