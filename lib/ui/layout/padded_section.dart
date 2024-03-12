import 'package:flutter/material.dart';

import '../diligence_theme.dart';

class PaddedSection extends StatelessWidget {
  final Widget child;

  const PaddedSection({super.key, required this.child});

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
