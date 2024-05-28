import 'notice.dart';

class ErrorNotice extends Notice {
  @override
  final String type = 'error';

  @override
  final String title;

  @override
  final String? details;

  ErrorNotice({
    super.uuid,
    required super.createdAt,
    required this.title,
    this.details,
  });
}
