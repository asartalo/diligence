import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  final String text;
  PageTitle(this.text);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 60),
      child: Text(
        text,
        style: theme.textTheme.headline2,
      ),
    );
  }
}
