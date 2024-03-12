import 'package:flutter/material.dart';

import '../../diligence_theme.dart';

class DataTitle extends StatelessWidget {
  final String text;
  const DataTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));

    return Text(
      text.toUpperCase(),
      style: diligenceTheme.text.dataTitle,
    );
  }
}
