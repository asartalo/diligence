import 'package:diligence/ui/components/typography/data_title.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';
import '../easy_card.dart';

class SingleNumberDataPointHorizontal extends StatelessWidget {
  final String title;
  final String caption;
  final num number;

  const SingleNumberDataPointHorizontal({
    @required this.title,
    @required this.caption,
    @required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    final textTheme = diligenceTheme.textTheme;
    return EasyCard(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataTitle(title),
                const SizedBox(height: 10.0),
                Text(caption, style: textTheme.caption),
              ],
            ),
            Text("$number", style: textTheme.headline3),
          ],
        ),
      ],
    );
  }
}
