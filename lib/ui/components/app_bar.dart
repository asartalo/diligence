import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'clock_wrap.dart';
import 'keys.dart' as keys;

AppBar appBar(BuildContext context, String title) {
  final theme = Theme.of(context);
  final titleStyle = theme.textTheme.titleLarge!.merge(
    TextStyle(
      color: theme.textTheme.bodyLarge!.color,
    ),
  );
  final dateFormat = DateFormat('EEEE, MMMM d, y H:mm a');

  return AppBar(
    leading: IconButton(
      key: keys.appBarMenuButton,
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
          child: ClockWrap(
            clockCallback: (time) => Text(
              dateFormat.format(time),
              style: theme.textTheme.bodyMedium,
            ),
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
