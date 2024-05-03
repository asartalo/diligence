import '../../services/notices/notice_row_data.dart';
import 'notice.dart';

class GenericNotice extends Notice {
  @override
  final String title;

  @override
  final String? details;

  GenericNotice({
    super.uuid,
    required super.createdAt,
    required this.title,
    this.details,
  });

  @override
  List<Object?> get props => [createdAt, title, details];

  @override
  NoticeRowData toRowData() {
    return NoticeRowData(
      uuid: uuid,
      type: 'generic',
      createdAt: createdAt,
      title: title,
      details: details,
    );
  }
}
