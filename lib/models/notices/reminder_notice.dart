import '../../services/diligent.dart';
import '../task.dart';
import 'notice.dart';

class ReminderNotice extends Notice {
  final Task task;
  final Diligent diligent;

  @override
  int? get taskId => task.id;

  @override
  String get title => 'Reminder: ${task.name}';

  @override
  String? get details => null;

  @override
  final String type = 'reminder';

  ReminderNotice({
    super.uuid,
    required this.task,
    required this.diligent,
    required super.createdAt,
  });

  Future<void> focusTask() async {
    await diligent.focus(task);
  }

  @override
  List<NoticeAction> actions() {
    return [NoticeAction('Focus', focusTask)];
  }
}
