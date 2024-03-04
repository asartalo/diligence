import '../models/commands/command.dart';
import '../models/task.dart';

typedef VoidCallback = void Function();
typedef TaskCallback = void Function(Task task);
typedef TaskIndexCallback = void Function(Task task, int index);
typedef TaskCommandCallback = void Function(Command command);
