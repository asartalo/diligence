import 'package:integration_test/integration_test.dart';

import './features/focus_tasks_test.dart' as features_focus_tasks_test;
import './features/reviews/day_log_test.dart' as features_reviews_day_log_test;
import './features/smoke_test.dart' as features_smoke_test;
import './features/tasks_crud_test.dart' as features_tasks_crud_test;
import './features/tasks_reordering_test.dart'
    as features_tasks_reordering_test;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await features_reviews_day_log_test.main();
  await features_smoke_test.main();
  await features_tasks_reordering_test.main();
  await features_tasks_crud_test.main();
  await features_focus_tasks_test.main();
}
