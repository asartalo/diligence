import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/ui/components/data/single_number.dart';
import 'package:diligence/ui/components/data/single_number_horizontal.dart';
import 'package:diligence/ui/components/easy_card.dart';
import 'package:diligence/ui/layout/even_row.dart';
import 'package:flutter/material.dart';

class MainSummarySection extends StatelessWidget {
  final ReviewSummaryData summaryData;

  MainSummarySection({@required this.summaryData});

  @override
  Widget build(BuildContext context) {
    return EasyCard(
      children: [
        EvenRow(
          children: [
            SingleNumberDataPoint(
              title: 'Completed Tasks',
              number: summaryData.completed,
            ),
            SingleNumberDataPoint(
              title: 'Overdue',
              number: summaryData.overdue,
            ),
            SingleNumberDataPoint(
              title: 'New Tasks',
              number: summaryData.newlyCreated,
            ),
          ],
        ),
        EvenRow(
          children: [
            SingleNumberDataPointHorizontal(
              title: 'Daily net tasks',
              caption: 'completed + destroyed - added',
              number: summaryData.dailyNetTasks,
            ),
            SingleNumberDataPointHorizontal(
              title: 'Task Completion Rate',
              caption: 'completed / 16 hours (TEMPORARY)',
              number: summaryData.hourlyTaskCompletionRate,
            ),
          ],
        ),
      ],
    );
  }
}
