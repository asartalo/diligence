import 'package:equatable/equatable.dart';

import '../../models/row_data.dart';
import '../../utils/date_time_from_row_epoch.dart';

class NoticeRowData extends Equatable {
  final String uuid;
  final String type;
  final DateTime createdAt;
  final String? title;
  final String? details;
  final int? taskId;

  @override
  final bool stringify = true;

  const NoticeRowData({
    required this.uuid,
    required this.type,
    required this.createdAt,
    this.title,
    this.details,
    this.taskId,
  });

  factory NoticeRowData.fromRowData(RowData row) {
    return NoticeRowData(
      uuid: row['uuid'] as String,
      type: row['type'] as String,
      createdAt: dateTimeFromRowEpoch(row['createdAt']),
      title: row['title'] as String?,
      details: row['details'] as String?,
      taskId: row['taskId'] as int?,
    );
  }

  RowData toRowData() {
    return {
      'uuid': uuid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'title': title,
      'details': details,
      'taskId': taskId,
    };
  }

  static List<String> fields() {
    return ['uuid', 'createdAt', 'type', 'title', 'details', 'taskId'];
  }

  List<Object?> rowValues() {
    final data = toRowData();
    return NoticeRowData.fields().map((key) => data[key]).toList();
  }

  @override
  List<Object?> get props => rowValues();
}
