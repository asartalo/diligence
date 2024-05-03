import '../../services/diligent.dart';
import '../../services/notices/notice_row_data.dart';
import '../task.dart';
import 'notice.dart';

class ReminderNotice extends Notice {
  final Task task;
  final Diligent diligent;

  @override
  String get title => 'Reminder: ${task.name}';

  @override
  String? get details => null;

  ReminderNotice({
    super.uuid,
    required this.task,
    required this.diligent,
    required super.createdAt,
  });

  @override
  List<Object?> get props => [createdAt, task.uid];

  Future<void> focusTask() async {
    await diligent.focus(task);
  }

  @override
  NoticeRowData toRowData() {
    return NoticeRowData(
      uuid: uuid,
      type: 'reminder',
      createdAt: createdAt,
      taskId: task.id,
    );
  }

  @override
  List<NoticeAction> actions() {
    return [NoticeAction('Focus', focusTask)];
  }
}
