import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, String title) {
  final theme = Theme.of(context);
  final titleStyle = theme.textTheme.titleLarge!.merge(
    TextStyle(
      color: theme.textTheme.bodyLarge!.color,
    ),
  );
  return AppBar(
    leading: IconButton(
      key: const Key('appBarMenuButton'),
      icon: Icon(
        Icons.menu,
        color: theme.textTheme.bodyLarge!.color,
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
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ),
    ],
    title: Text(
      title,
      style: titleStyle,
    ),
    backgroundColor: theme.scaffoldBackgroundColor,
    shadowColor: Colors.transparent,
  );
}
