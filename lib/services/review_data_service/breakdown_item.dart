part of '../review_data_service.dart';

@immutable
class BreakdownItem {
  final List<int> path;
  final num value;

  const BreakdownItem({
    required this.path,
    required this.value,
  });
}
