import 'package:intl/intl.dart';

final timeFormat = DateFormat.jm();
final dateFormat = DateFormat.yMMMMd();
final dateFormatWithDay = DateFormat.EEEE().addPattern(', ', '').add_yMMMMd();
final dateTimeFormat = dateFormatWithDay.add_jm();
// final dateFormatNoDay = DateFormat('MMMM d, y');
