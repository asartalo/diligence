import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const defaultColors = [
  Colors.green,
  Colors.orange,
  Colors.blue,
  Colors.red,
];

class EasyPieChart extends StatelessWidget {
  final double radius;
  final Map<String, double> data;
  List<Color> get colors => defaultColors;

  const EasyPieChart(this.data, {this.radius = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PieChart(
      PieChartData(
        centerSpaceRadius: 0,
        sections: chartDataFromMap(theme),
        borderData: FlBorderData(
          show: false,
        ),
      ),
    );
  }

  List<PieChartSectionData> chartDataFromMap(ThemeData theme) {
    if (colors == null) {
      throw Exception('Please provide colors');
    }
    if (colors.isEmpty) {
      throw Exception('The colors provided is empty');
    }

    var i = 0;
    return data.entries.map((entry) {
      final datum = PieChartSectionData(
        color: colors[i % colors.length],
        value: entry.value,
        radius: radius,
        title: entry.key,
        titleStyle: theme.textTheme.bodyText2.copyWith(color: Colors.white),
      );
      i++;
      return datum;
    }).toList();
  }
}
