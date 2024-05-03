import 'package:diligence/models/notices/generic_notice.dart';
import 'package:diligence/models/notices/notice.dart';
import 'package:diligence/services/notices/notice_queue.dart';
import 'package:diligence/utils/clock.dart';
import 'package:diligence/utils/stub_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite_async/sqlite_async.dart';

void main() {
  group('NoticeQueue', () {
    late NoticeQueue noticeQueue;
    late Clock clock;
    final initialNow = DateTime(2024, 4, 12, 16);

    setUp(() async {
      final testDb = SqliteDatabase(path: 'test_job_scheduler.db');
      clock = StubClock(initialNow);
      noticeQueue = NoticeQueue(
        db: testDb,
        clock: clock,
        isTest: true,
        noticeFactoryFunc: genericNoticeFactoryFunc,
      );
      await noticeQueue.runMigrations();
    });

    tearDown(() async {
      await noticeQueue.clearDataForTests();
    });

    group('When a notice is added', () {
      late Notice note;

      setUp(() async {
        note = GenericNotice(title: 'Foo', createdAt: initialNow);
        await noticeQueue.addNotice(note);
      });

      test('it persists notice', () async {
        final queue = await noticeQueue.getNotices();
        expect(queue, [note]);
      });
    });

    group('When a notice is dismissed', () {
      late Notice note;

      setUp(() async {
        note = GenericNotice(title: 'Foo', createdAt: clock.now());
        await noticeQueue.addNotice(note);
        await noticeQueue.dismissNotice(note);
      });

      test('it is removed from the queue', () async {
        final queue = await noticeQueue.getNotices();
        expect(queue, isEmpty);
      });
    });
  });
}
