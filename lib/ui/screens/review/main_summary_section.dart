import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/ui/components/data/single_number.dart';
import 'package:diligence/ui/components/data/single_number_horizontal.dart';
import 'package:diligence/ui/layout/even_row.dart';
import 'package:flutter/material.dart';

const basicData = [
  {'genre': 'Sports', 'sold': 275},
  {'genre': 'Strategy', 'sold': 115},
  {'genre': 'Action', 'sold': 120},
  {'genre': 'Shooter', 'sold': 350},
  {'genre': 'Other', 'sold': 150},
];

class MainSummarySection extends StatelessWidget {
  final ReviewSummaryData summaryData;

  const MainSummarySection({required this.summaryData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EvenRow(
          gutter: 10.0,
          children: [
            SingleNumberDataPoint(
              title: 'Completed',
              number: summaryData.completed,
              // number: 21,
            ),
            SingleNumberDataPoint(
              title: 'Overdue',
              icon: Icons.alarm,
              color: Colors.red,
              number: summaryData.overdue,
              // number: 8,
            ),
            SingleNumberDataPoint(
              title: 'New Tasks',
              icon: Icons.add,
              color: Colors.blue,
              number: summaryData.newlyCreated,
              // number: 17,
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        EvenRow(
          gutter: 10.0,
          children: [
            SingleNumberDataPointHorizontal(
              title: 'Daily net tasks',
              caption: 'completed + destroyed - added',
              number: summaryData.dailyNetTasks,
            ),
            SingleNumberDataPointHorizontal(
              title: 'Completion Rate',
              caption: 'completed / 16 hours (TEMPORARY)',
              number: summaryData.hourlyTaskCompletionRate,
            ),
          ],
        ),
      ],
    );
  }
}
