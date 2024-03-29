import 'package:integration_test/integration_test.dart';
import './features/reviews/day_log_test.dart' as features_reviews_day_log_test;
import './features/smoke_test.dart' as features_smoke_test;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await features_reviews_day_log_test.main();
  await features_smoke_test.main();
}
