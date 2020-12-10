import 'package:flutter/material.dart';

import '../../theme.dart';

class SingleNumberDataPointHorizontal extends StatelessWidget {
  final String title;
  final String caption;
  final num number;

  SingleNumberDataPointHorizontal({
    @required this.title,
    @required this.caption,
    @required this.number,
  });

  @override
  Widget build(BuildContext context) {
    var diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    var textTheme = diligenceTheme.textTheme;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: diligenceTheme.text.dataTitle),
                  Text(caption, style: textTheme.caption),
                ],
              ),
            ),
            Text("$number", style: textTheme.headline4),
          ],
        ),
      ),
    );
  }
}
