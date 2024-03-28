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

import 'package:flutter/foundation.dart';

import '../diligence_config.dart';

abstract class SideEffects {
  DateTime now();
}

class ProductionSideEffects extends SideEffects {
  @override
  DateTime now() => DateTime.now();
}

DateTime _toDate(DateTime toConvert, DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
    toConvert.hour,
    toConvert.minute,
    toConvert.second,
    toConvert.millisecond,
    toConvert.microsecond,
  );
}

@immutable
class DevSideEffects extends SideEffects {
  final DiligenceConfig config;
  DevSideEffects(this.config) : super();

  @override
  DateTime now() {
    final realNow = DateTime.now();
    if (config.today == null) {
      return realNow;
    }

    return _toDate(realNow, config.today!);
  }
}
