import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String text;
  const PageTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 60),
      child: Text(
        text,
        style: theme.textTheme.displayMedium,
      ),
    );
  }
}
