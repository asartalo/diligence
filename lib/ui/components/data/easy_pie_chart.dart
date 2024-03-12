import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const defaultColors = [
  Colors.green,
  Colors.orange,
  Colors.blue,
  Colors.red,
];

typedef DataToPieChartSectionData = PieChartSectionData Function(
  MapEntry<String, double>,
);

class EasyPieChart extends StatelessWidget {
  final double radius;
  final Map<String, double> data;
  List<Color> get colors => defaultColors;

  const EasyPieChart(this.data, {super.key, this.radius = 200});

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: _sections(),
        centerSpaceRadius: 0,
        sectionsSpace: 1,
      ),
    );
  }

  List<PieChartSectionData> _sections() {
    return data.entries.map<PieChartSectionData>(_dataMapper()).toList();
  }

  DataToPieChartSectionData _dataMapper() {
    int i = -1;
    final colorsCount = defaultColors.length;

    return (entry) {
      i += 1;

      return PieChartSectionData(
        value: entry.value,
        color: defaultColors[i % colorsCount],
        title: entry.key,
        radius: 120,
      );
    };
  }
}
