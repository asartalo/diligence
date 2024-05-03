import 'package:equatable/equatable.dart';

import '../../services/notices/notice_row_data.dart';
import '../../utils/uuidv4.dart';

typedef ActionFunc = dynamic Function();

class NoticeAction extends Equatable {
  final String label;
  final ActionFunc action;

  const NoticeAction(this.label, this.action);

  @override
  List<Object?> get props => [label, action];
}

abstract class Notice extends Equatable {
  final String uuid;
  final DateTime createdAt;
  String get title;
  String? get details;

  Notice({required this.createdAt, String? uuid}) : uuid = uuid ?? uuidv4();

  NoticeRowData toRowData();

  List<NoticeAction> actions() => [];
}
