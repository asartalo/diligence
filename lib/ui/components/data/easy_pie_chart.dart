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
    return Text('Pie chart - ${data.entries.toString()}');
  }
}
