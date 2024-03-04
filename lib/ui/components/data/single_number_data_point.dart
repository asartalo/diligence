import 'package:flutter/material.dart';

import '../../diligence_theme.dart';
import '../easy_card.dart';
import '../typography/data_title.dart';

class SingleNumberDataPoint extends StatelessWidget {
  final String title;
  final num number;
  final IconData icon;
  final Color color;
  const SingleNumberDataPoint({
    required this.title,
    required this.number,
    this.icon = Icons.check,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    final diligenceTheme = DiligenceTheme.fromTheme(Theme.of(context));
    final space = diligenceTheme.lengths.space;
    final textTheme = diligenceTheme.textTheme;

    return EasyCard(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, space * .5, 0, space * 1.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 48.0,
                color: color,
              ),
              Text(
                "$number",
                style: textTheme.displayMedium,
              ),
              const SizedBox(height: 5.0),
              DataTitle(title),
            ],
          ),
        ),
      ],
    );
  }
}
