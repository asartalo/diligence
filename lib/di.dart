import 'package:clock/clock.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'di_scope_cache.dart';
import 'services/diligent.dart';

class Di {
  final String dbPath;

  final Clock clock;

  final bool isTest;

  Di({
    this.dbPath = 'diligence.db',
    Clock? clock,
    this.isTest = false,
  }) : clock = clock ?? const Clock();

  final DiScopeCache _cache = DiScopeCache();

  Diligent get diligent => _cache.getSet(
      #diligent,
      () => Diligent.convenience(
            isTest: isTest,
            db: db,
            clock: clock,
          ));

  SqliteDatabase get db =>
      _cache.getSet(#db, () => SqliteDatabase(path: dbPath));
}
