import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, String title) {
  final theme = Theme.of(context);
  final titleStyle = theme.textTheme.headline6.merge(TextStyle(
    color: theme.textTheme.bodyText1.color,
  ));
  return AppBar(
    leading: IconButton(
      icon: Icon(
        Icons.menu,
        color: theme.textTheme.bodyText1.color,
      ),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
    ),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Center(
          child: Text(
            'Mon November 23, 2020  5:07 PM',
            style: theme.textTheme.bodyText2,
          ),
        ),
      ),
    ],
    title: Text(
      title,
      style: titleStyle,
    ),
    // backgroundColor: theme.backgroundColor.withOpacity(0.5),
    backgroundColor: theme.accentColor,
    // backgroundColor: Colors.deepOrange,
    shadowColor: Colors.transparent,
  );
}
