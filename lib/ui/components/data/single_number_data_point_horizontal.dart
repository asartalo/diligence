import 'package:flutter/material.dart';

import '../../diligence_theme.dart';
import '../easy_card.dart';
import '../typography/data_title.dart';

class SingleNumberDataPointHorizontal extends StatelessWidget {
  final String title;
  final String caption;
  final num number;

  const SingleNumberDataPointHorizontal({
    super.key,
    required this.title,
    required this.caption,
    required this.number,
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
                Text(caption, style: textTheme.bodySmall),
              ],
            ),
            Text("$number", style: textTheme.displaySmall),
          ],
        ),
      ],
    );
  }
}
