import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, String title) {
  var theme = Theme.of(context);
  return AppBar(
    leading: ,
    title: Text(
      title,
      style: theme.textTheme.headline6.merge(TextStyle(
        color: theme.textTheme.bodyText1.color,
      )),
    ),
    backgroundColor: theme.backgroundColor,
    shadowColor: Colors.transparent,
  );
}
