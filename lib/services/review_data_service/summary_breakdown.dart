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

Function listEquals = const ListEquality<int>().equals;

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
    // ignore: avoid_dynamic_calls
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
