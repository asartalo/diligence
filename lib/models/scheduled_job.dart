import 'package:equatable/equatable.dart';
import 'package:uuid/v4.dart';

const generator = UuidV4();

abstract class ScheduledJob extends Equatable {
  final String uuid;
  final DateTime runAt;
  final String type;

  ScheduledJob({
    String? uuid,
    required this.runAt,
    required this.type,
  }) : uuid = uuid ?? generator.generate();

  @override
  List<Object?> get props => [uuid, runAt, type];
}
