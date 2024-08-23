import 'package:equatable/equatable.dart';

import '../utils/uuidv4.dart';

abstract class ScheduledJob extends Equatable {
  final String uuid;
  final DateTime runAt;
  final String type;

  ScheduledJob({
    String? uuid,
    required this.runAt,
    required this.type,
  }) : uuid = uuid ?? uuidv4();

  @override
  List<Object?> get props => [uuid, runAt, type];

  @override
  String toString() {
    return 'ScheduledJob ($type) $uuid $runAt';
  }
}
