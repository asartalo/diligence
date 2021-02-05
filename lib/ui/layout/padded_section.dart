import 'package:flutter/material.dart';

import '../theme.dart';

class PaddedSection extends StatelessWidget {
  final Widget child;

  const PaddedSection({required this.child});

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    final space = diligenceTheme.lengths.space;
    return Padding(
      padding: EdgeInsets.all(space),
      child: child,
    );
  }
}
