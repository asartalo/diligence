import 'package:uuid/v4.dart';

const _generator = UuidV4();

String uuidv4() => _generator.generate();
