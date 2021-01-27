part of '../review_data_service.dart';

@immutable
class ReviewSummaryData extends Equatable {
  final int completed;
  final int overdue;
  final int newlyCreated;
  final String notes;

  // final double hourlyTaskCompletionRate; // tasks completed per hour within working hours
  const ReviewSummaryData({
    @required this.completed,
    @required this.overdue,
    @required this.newlyCreated,
    @required this.notes,
  });

  // TODO: include destroyed or trashed in calculation
  // = completed + destroyed - added
  int get dailyNetTasks => completed - newlyCreated;

  double get hourlyTaskCompletionRate => completed / 16.0;

  @override
  List<Object> get props => [completed, overdue, newlyCreated];
}
