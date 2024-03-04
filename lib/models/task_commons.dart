import 'task.dart';

mixin TaskCommons implements Task {
  String? normalizedDetails(String? str) {
    if (str is String && str.trim().isEmpty) {
      return null;
    }

    return str ?? details;
  }

  DateTime? normalizedDoneAt(bool? doneIntent, DateTime? dt) {
    if (doneIntent == null) {
      if (dt == null) {
        return doneAt;
      }
      if (dt != doneAt) {
        return dt;
      }
    }

    if (doneIntent == done) {
      if (dt is DateTime && dt != doneAt) {
        return dt;
      }

      return doneAt;
    }

    if (doneIntent == true) {
      return DateTime.now();
    }

    return null;
  }

  @override
  Task markDone() {
    return copyWith(done: true);
  }

  @override
  Task markNotDone() {
    return copyWith(done: false);
  }
}
