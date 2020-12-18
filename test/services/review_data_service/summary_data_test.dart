import 'package:diligence/services/review_data_service.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() async {
  ReviewSummaryData summaryData;

  setUp(() {
    summaryData = const ReviewSummaryData(
      completed: 8,
      overdue: 6,
      newlyCreated: 4,
    );
  });

  group('ReviewSummaryData', () {
    test('calculates dailyNetTasks', () {
      // = completed + destroyed - added
      expect(summaryData.dailyNetTasks, 4);
    });

    test('calculates hourlyTaskCompletionRate', () {
      // TODO: implement this better when we have settings for endOfDay
      // endOfDay is counterpart of settings startOfDay
      // for now let's assume 16 hours of work
      expect(summaryData.hourlyTaskCompletionRate, 8.0 / 16.0);
    });
  });
}
