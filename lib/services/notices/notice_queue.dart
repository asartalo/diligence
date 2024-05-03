import 'dart:async';

import 'package:sqlite_async/sqlite_async.dart';

import '../../models/notices/generic_notice.dart';
import '../../models/notices/notice.dart';
import '../../utils/clock.dart';
import '../migrate.dart';
import 'notice_row_data.dart';

typedef NoticeList = List<Notice>;
typedef NoticesStream = Stream<NoticeList>;

typedef NoticeFactoryFunc<T extends Notice> = Future<T> Function(
    NoticeRowData row);

Future<GenericNotice> genericNoticeFactoryFunc(NoticeRowData data) async {
  return GenericNotice(
    uuid: data.uuid,
    createdAt: data.createdAt,
    title: data.title!,
    details: data.details,
  );
}

class NoticeQueue {
  final SqliteDatabase db;
  final Clock clock;
  final bool _isTest;
  final NoticeFactoryFunc<Notice> noticeFactoryFunc;
  MultiStreamController<NoticeList>? _streamController;
  late NoticesStream stream = Stream<NoticeList>.multi(_prepareController);

  NoticeQueue({
    required bool isTest,
    required this.db,
    required this.clock,
    required this.noticeFactoryFunc,
  }) : _isTest = isTest;

  void _prepareController(MultiStreamController<NoticeList> controller) {
    _streamController = controller;
  }

  Future<void> runMigrations() async {
    await migrations.migrate(db);
  }

  Future<void> clearDataForTests() async {
    if (_isTest) {
      await db.execute('DELETE FROM notices');
    }
  }

  String? _addNoticeQuery;

  Future<void> addNotice(Notice notice) async {
    final rowData = notice.toRowData();
    final fields = NoticeRowData.fields();
    await db.execute(
      _addNoticeQuery ??= '''
      INSERT INTO notices (${fields.join(', ')})
      VALUES (${fields.map((_) => '?').join(', ')})
      ''',
      rowData.rowValues(),
    );
    _updateStream();
  }

  Future<void> _updateStream() async {
    if (_streamController is StreamController &&
        _streamController!.hasListener) {
      _streamController!.add(await getNotices());
    }
  }

  Future<List<Notice>> getNotices() async {
    final rows = await db.getAll(
      '''
      SELECT * FROM notices
      ORDER BY createdAt
      ''',
    );
    final notices = <Notice>[];
    for (final row in rows) {
      final rowData = NoticeRowData.fromRowData(row);
      notices.add(await noticeFactoryFunc(rowData));
    }
    return notices;
  }

  Future<void> dismissNotice(Notice notice) async {
    await db.execute(
      'DELETE FROM notices WHERE uuid = ?',
      [notice.uuid],
    );
    _updateStream();
  }
}
