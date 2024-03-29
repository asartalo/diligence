// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

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
