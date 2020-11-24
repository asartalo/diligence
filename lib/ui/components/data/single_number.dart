import 'package:flutter/material.dart';

import '../../theme.dart';

class SingleNumberDataPoint extends StatelessWidget {
  final String title;
  final dynamic number;
  SingleNumberDataPoint({this.title, this.number});

  @override
  Widget build(BuildContext context) {
    var diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    var textTheme = diligenceTheme.textTheme;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: diligenceTheme.text.dataTitle,
            ),
            Text(
              "$number",
              style: textTheme.headline2,
            ),
          ],
        ),
      ),
    );
  }
}
