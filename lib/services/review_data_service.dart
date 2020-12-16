import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

class ReviewSummaryData extends Equatable {
  final int completed;
  final int overdue;
  final int newlyCreated;

  // TODO: these should be calculated
  // final double dailyNetTasks;
  // final double dailyTaskCompletionRate; // tasks completed per hour within working hours
  const ReviewSummaryData({
    @required this.completed,
    @required this.overdue,
    @required this.newlyCreated,
  });

  @override
  List<Object> get props => [completed, overdue, newlyCreated];
}

DateTimeRange getDayRange(DateTime now) {
  var start = DateTime(now.year, now.month, now.day);
  return DateTimeRange(
    start: start,
    end: start.add(Duration(days: 1)),
  );
}

class ReviewDataService {
  final Database db;
  static final String summarySql = '''
    SELECT count(id) as created 
    FROM tasks 
    WHERE created_at >= ? 
    AND created_at < ?;''';

  ReviewDataService(this.db);

  Future<ReviewSummaryData> getSummaryData(DateTime now) async {
    final dayRange = getDayRange(now);
    // TODO: Add conditional handling if there's no result
    var result = await db.rawQuery(
      summarySql,
      [dayRange.start.toString(), dayRange.end.toString()],
    );
    return ReviewSummaryData(
      completed: 24,
      overdue: 2,
      newlyCreated: result.first['created'],
    );
  }
}
