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

part of 'task_item.dart';

@immutable
class TaskItemStyle {
  final double checkboxXOffset;
  final double checkboxScale;
  final EdgeInsets contentPadding;
  final double leadSpacing;
  final double nameFontSize;
  final int marginLeft;
  final double trailSpacing;

  const TaskItemStyle({
    this.checkboxXOffset = 0.0,
    this.checkboxScale = 1.0,
    this.contentPadding = const EdgeInsets.fromLTRB(26, 2, 8, 2),
    this.leadSpacing = 0.0,
    this.nameFontSize = 18.0,
    this.marginLeft = 1,
    this.trailSpacing = 0.0,
  });

  TaskItemStyle copyWith({
    double? checkboxXOffset,
    double? checkboxScale,
    EdgeInsets? contentPadding,
    double? leadSpacing,
    double? nameFontSize,
    int? marginLeft,
    double? trailSpacing,
  }) {
    return TaskItemStyle(
      checkboxXOffset: checkboxXOffset ?? this.checkboxXOffset,
      checkboxScale: checkboxScale ?? this.checkboxScale,
      contentPadding: contentPadding ?? this.contentPadding,
      leadSpacing: leadSpacing ?? this.leadSpacing,
      nameFontSize: nameFontSize ?? this.nameFontSize,
      marginLeft: marginLeft ?? this.marginLeft,
      trailSpacing: trailSpacing ?? this.trailSpacing,
    );
  }
}

const normalTaskItemStyle = TaskItemStyle();
const focus1stTaskItemStyle = TaskItemStyle(
  checkboxScale: 2.0,
  contentPadding: EdgeInsets.fromLTRB(0, 16, 8, 16),
  leadSpacing: 4.0,
  nameFontSize: 48,
  marginLeft: 0,
  trailSpacing: 24.0,
);
const focus2ndTaskItemStyle = TaskItemStyle(
  checkboxScale: 1.2,
  contentPadding: EdgeInsets.fromLTRB(24, 8, 8, 8),
  leadSpacing: 8.0,
  nameFontSize: 32,
  trailSpacing: 12.0,
);
const focusOthersTaskItemStyle = normalTaskItemStyle;
final focus1stNarrowTaskItemStyle = focus2ndTaskItemStyle.copyWith(
  contentPadding: EdgeInsets.fromLTRB(6, 8, 8, 8),
  marginLeft: 0,
);
final focusOthersNarrowTaskItemStyle = focusOthersTaskItemStyle.copyWith(
  contentPadding: EdgeInsets.fromLTRB(4, 2, 8, 2),
  marginLeft: 1,
);
