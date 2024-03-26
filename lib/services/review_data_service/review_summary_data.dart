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

part of '../review_data_service.dart';

@immutable
class ReviewSummaryData extends Equatable {
  final int completed;
  final int overdue;
  final int newlyCreated;
  final String notes;

  // final double hourlyTaskCompletionRate; // tasks completed per hour within working hours
  const ReviewSummaryData({
    required this.completed,
    required this.overdue,
    required this.newlyCreated,
    required this.notes,
  });

  // TODO: include destroyed or trashed in calculation
  // = completed + destroyed - added
  int get dailyNetTasks => completed - newlyCreated;

  double get hourlyTaskCompletionRate => completed / 16.0;

  @override
  List<Object> get props => [completed, overdue, newlyCreated];
}
