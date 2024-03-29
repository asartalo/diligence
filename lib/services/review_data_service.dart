import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'review_data_service/summary_breakdown.dart';
part 'review_data_service/summary_data.dart';

DateTimeRange getDayRange(DateTime now) {
  final start = DateTime(now.year, now.month, now.day);
  return DateTimeRange(
    start: start,
    end: start.add(const Duration(days: 1)),
  );
}

class ReviewDataService {
  ReviewDataService();

  Future<ReviewSummaryData> getSummaryData(DateTime now) async {
    final dayRange = getDayRange(now);
    final created = await _calculateCreated(dayRange);
    final completed = await _calculateCompleted(dayRange);
    final overdue = await _calculateOverdue(dayRange);
    return ReviewSummaryData(
      notes: '',
      completed: completed,
      overdue: overdue,
      newlyCreated: created,
    );
  }

  Future<int> _calculateCreated(DateTimeRange range) async {
    return 7;
  }

  Future<int> _calculateCompleted(DateTimeRange range) async {
    return 5;
  }

  Future<int> _calculateOverdue(DateTimeRange range) async {
    return 13;
  }
}
