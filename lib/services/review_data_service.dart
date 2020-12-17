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
  static const String summarySql = '''
    SELECT count(id) as created 
    FROM tasks 
    WHERE created_at >= ? 
    AND created_at < ?;''';

  static const String overdueSql = '''
    SELECT SUM("task_defers"."duration") AS sum_duration,
           "task_defers"."task_id" AS task_id
    FROM "task_defers"
    WHERE "task_defers"."task_id" IN(
      SELECT "tasks"."id"
      FROM "tasks"
      WHERE "tasks"."done_at" >= ?
      AND "tasks"."done_at" < ?
    )
    GROUP BY "task_id"
    HAVING sum_duration > ?;
    ''';
  static const String completedSql = '''
    SELECT count(id) as completed 
    FROM tasks 
    WHERE done_at >= ? 
    AND done_at < ?;''';

  ReviewDataService(this.db);

  Future<ReviewSummaryData> getSummaryData(DateTime now) async {
    final dayRange = getDayRange(now);
    final created = await _calculateCreated(dayRange);
    final completed = await _calculateCompleted(dayRange);
    final overdue = await _calculateOverdue(dayRange);
    return ReviewSummaryData(
      completed: completed,
      overdue: overdue,
      newlyCreated: created,
    );
  }

  Future<int> _calculateCreated(DateTimeRange range) async {
    // TODO: Add conditional handling if there's no result
    var result = await db.rawQuery(
      summarySql,
      [range.start.toString(), range.end.toString()],
    );
    return result.first['created'];
  }

  Future<int> _calculateCompleted(DateTimeRange range) async {
    var result = await db.rawQuery(
      completedSql,
      [range.start.toString(), range.end.toString()],
    );
    return result.first['completed'];
  }

  Future<int> _calculateOverdue(DateTimeRange range) async {
    var settingsResult = await db.rawQuery('''
      SELECT max_idle_minutes
      FROM "settings"
      LIMIT 1;
    ''');
    var result = await db.rawQuery(
      overdueSql,
      [
        range.start.toString(),
        range.end.toString(),
        settingsResult.first['max_idle_minutes'] * 60
      ],
    );
    return result.length;
  }
}
