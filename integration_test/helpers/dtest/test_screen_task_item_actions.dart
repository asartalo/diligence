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

import 'package:diligence/ui/screens/tasks/keys.dart' as tkeys;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_screen.dart';

mixin TestScreenTaskItemActions on TestScreen {
  Future<void> showTask(String name) async {
    final task = findTaskItem(name);
    await dtest.tapElement(task);
  }

  Finder findTaskItem(String name) {
    final taskNameText = find.descendant(
      of: taskList,
      matching: find.text(name),
    );

    return find.ancestor(
        of: taskNameText, matching: find.byKey(tkeys.taskItem));
  }

  Future<void> tapTaskMenuItem(String name, Key key) async {
    final task = findTaskItem(name);
    final menuButton = find.descendant(
      of: task,
      matching: find.byKey(tkeys.taskMenu),
    );
    await dtest.tapElement(menuButton);
    final button = find.descendant(
      of: task,
      matching: find.byKey(key),
    );
    await dtest.tapElement(button);
  }

  Future<void> tapTaskMenuAdd(String name) =>
      tapTaskMenuItem(name, tkeys.taskMenuAdd);

  Future<void> tapTaskMenuDelete(String name) =>
      tapTaskMenuItem(name, tkeys.taskMenuDelete);

  Future<void> tapTaskMenuEdit(String name) =>
      tapTaskMenuItem(name, tkeys.taskMenuEdit);

  Future<void> tapTaskMenuFocus(String name) async {
    await tapTaskMenuItem(name, tkeys.taskMenuFocus);
  }

  Future<void> tapTaskMenuUnfocus(String name) =>
      tapTaskMenuItem(name, tkeys.taskMenuUnfocus);

  Future<void> moveTask(
    String name, {
    required String to,
    Duration? duration,
  }) async {
    final task = findTaskItem(name);
    final destination = findTaskItem(to);
    final fromCoords = tester.getCenter(task);
    final toCoords = tester.getCenter(destination);
    await dtest.longPressThenDrag(
      fromCoords,
      toCoords.translate(
        0,
        // Offset so we make sure to get past the destination
        fromCoords.dy > toCoords.dy ? 5 : -5,
      ),
      duration: duration,
    );
  }

  Future<void> inputTaskDetails({
    String? name,
    String? details,
  }) async {
    if (name is String) {
      await dtest.enterTextByKey(tkeys.taskNameField, name);
    }
    if (details is String) {
      await dtest.enterTextByKey(tkeys.taskDetailsField, details);
    }
    await dtest.tapByKey(tkeys.saveTaskButton);
  }

  Future<void> toggleExpand(String name) async {
    final task = findTaskItem(name);
    final expandToggle = find.descendant(
      of: task,
      matching: find.byKey(tkeys.taskExpandButton),
    );
    await dtest.tapElement(expandToggle);
  }
}
