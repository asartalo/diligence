import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../theme.dart';

class SingleNumberDataPoint extends StatelessWidget {
  final String title;
  final num number;
  SingleNumberDataPoint({
    @required this.title,
    @required this.number,
  });

  @override
  Widget build(BuildContext context) {
    var diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    var space = diligenceTheme.lengths.space;
    var textTheme = diligenceTheme.textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(space, space * 2, space, space * 2),
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
    );
  }
}