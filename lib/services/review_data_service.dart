import 'package:collection/collection.dart';
import 'package:diligence/constants.dart';
import 'package:diligence/utils/cast.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

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
    final result = await db.rawQuery(
      summarySql,
      [range.start.toString(), range.end.toString()],
    );
    return castOrDefault<int>(result.first['created'], 0);
  }

  Future<int> _calculateCompleted(DateTimeRange range) async {
    final result = await db.rawQuery(
      completedSql,
      [range.start.toString(), range.end.toString()],
    );
    return castOrDefault<int>(result.first['completed'], 0);
  }

  Future<int> _calculateOverdue(DateTimeRange range) async {
    final settingsResult = await db.rawQuery('''
      SELECT max_idle_minutes
      FROM "settings"
      LIMIT 1;
    ''');
    final maxIdleMinutes = settingsResult.isNotEmpty
        ? settingsResult.first['max_idle_minutes']
        : kDefaultMaxIdleMinutes;
    final result = await db.rawQuery(
      overdueSql,
      [range.start.toString(), range.end.toString(), maxIdleMinutes * 60],
    );
    return result.length;
  }
}
