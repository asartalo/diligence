// Diligence - A Task Management App
//
// Copyright (C) 2025 Wayne Duran <asartalo@gmail.com>
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

import '../../di/app_state_scope.dart';
import '../../di/root_scope.dart';
import '../../diligence_config.dart';
import '../../utils/clock.dart';
import 'diligent.dart';

const testDbPath = 'diligence_test.db';

class DiligentFactory {
  static Diligent forUnitTests({String? dbPath, Clock? clock}) {
    final RootScope rootScope = RootScope(clock: clock, isTest: true);
    final config = DiligenceConfig(dbPath: dbPath ?? testDbPath);
    final appScope = AppStateScope(parent: rootScope, config: config);

    return appScope.diligent;
  }
}
