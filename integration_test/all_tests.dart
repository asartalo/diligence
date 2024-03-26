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

import 'package:integration_test/integration_test.dart';

import './features/expanding_tasks_test.dart' as features_expanding_tasks_test;
import './features/focus_tasks_test.dart' as features_focus_tasks_test;
import './features/reviews/day_log_test.dart' as features_reviews_day_log_test;
import './features/smoke_test.dart' as features_smoke_test;
import './features/tasks_crud_test.dart' as features_tasks_crud_test;
import './features/tasks_reordering_test.dart'
    as features_tasks_reordering_test;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await features_expanding_tasks_test.main();
  await features_reviews_day_log_test.main();
  await features_smoke_test.main();
  await features_tasks_reordering_test.main();
  await features_tasks_crud_test.main();
  await features_focus_tasks_test.main();
}
