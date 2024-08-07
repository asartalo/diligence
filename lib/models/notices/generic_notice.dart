import 'notice.dart';

class GenericNotice extends Notice {
  @override
  final String type = 'generic';

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
}
