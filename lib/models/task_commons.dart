import 'task.dart';

mixin TaskCommons implements Task {
  String? normalizedDetails(String? str) {
    if (str is String && str.trim().isEmpty) {
      return null;
    }
    return str ?? details;
  }
}
