import 'package:flutter/material.dart';

import '../theme.dart';

class PaddedSection extends StatelessWidget {
  final Widget child;

  PaddedSection({this.child});

  @override
  Widget build(BuildContext context) {
    var diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    var space = diligenceTheme.lengths.space;
    return Padding(
      padding: EdgeInsets.all(space),
      child: child,
    );
  }
}
