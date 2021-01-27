import 'package:diligence/services/review_data_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SummaryBreakdown summaryBreakdown;

  // The Structure Structure:
  // Life Goals 1
  // - Be Rich 4
  //   - Find Work 8
  //     - Prepare Resume 9
  //     - Look for Companies Hiring 10
  // - Be Healthy 5
  //   - Find a Nutritionist 11
  //   - Have an Exercise Plan 12
  // Work 2
  // - Apply for Jobs 6
  // Projects 3
  // - The Social Network 7

  setUp(() {
    summaryBreakdown = SummaryBreakdown(name: 'Newly Created', items: const [
      BreakdownItem(value: 1, path: [1, 4, 8, 9]),
      BreakdownItem(value: 1, path: [1, 4, 8, 10]),
      BreakdownItem(value: 0.5, path: [1, 5, 11]),
      BreakdownItem(value: 1, path: [1, 5, 12]),
      BreakdownItem(value: 1, path: [2, 6]),
      BreakdownItem(value: 1, path: [3, 7]),
    ]);
  });

  test('it returns total', () {
    expect(summaryBreakdown.total, equals(5.5));
  });

  test('it breaks down a level', () {
    expect(
      summaryBreakdown.breakdown(),
      equals({
        1: 3.5, // Life Goals
        2: 1, // Work
        3: 1, // Projects
      }),
    );
  });

  test('it breaks down another level', () {
    expect(summaryBreakdown.breakdown([1]), equals({4: 2, 5: 1.5}));
  });

  test('it breaks down yet another level', () {
    expect(
      summaryBreakdown.breakdown([1, 4, 8]),
      equals({
        9: 1, // Prepare Resume
        10: 1, // Look for Companies Hiring
      }),
    );
  });
}
