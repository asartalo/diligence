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

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'review_data_service/breakdown_item.dart';
part 'review_data_service/summary_breakdown.dart';
part 'review_data_service/review_summary_data.dart';

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

    return ReviewSummaryData(
      notes: '',
      completed: await _calculateCompleted(dayRange),
      overdue: await _calculateOverdue(dayRange),
      newlyCreated: await _calculateCreated(dayRange),
    );
  }

  Future<int> _calculateCreated(DateTimeRange _) async {
    return 7;
  }

  Future<int> _calculateCompleted(DateTimeRange _) async {
    return 5;
  }

  Future<int> _calculateOverdue(DateTimeRange _) async {
    return 13;
  }
}
