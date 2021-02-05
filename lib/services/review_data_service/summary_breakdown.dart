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

Function listEquals = const ListEquality().equals;

@immutable
class SummaryBreakdown {
  final String name;
  final List<BreakdownItem> items;

  num get total {
    return items.fold(0, (p, item) => p + item.value);
  }

  List<int> _pathMatch(List<int> levels, List<int> path) {
    if (levels.isEmpty) {
      return path;
    }
    if (levels.length > path.length) {
      return [];
    }
    final subPath = path.sublist(0, levels.length);
    final equal = listEquals(subPath, levels) as bool;
    if (!equal) {
      return [];
    }
    return path.sublist(levels.length);
  }

  Map<int, num> breakdown([List<int> path = const []]) {
    return items.fold<Map<int, num>>({}, (map, item) {
      final match = _pathMatch(path, item.path);
      if (match.isNotEmpty) {
        // print(match);
        final key = match.first;
        final value = map[key] ?? 0.0;
        map[key] = value + item.value;
      }
      return map;
    });
  }

  const SummaryBreakdown({
    required this.name,
    required this.items,
  });
}
