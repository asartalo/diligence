import 'package:sqlite_async/sqlite_async.dart';

import 'migrations.dart';

SqliteMigrations migrate() {
  final SqliteMigrations migrations = SqliteMigrations();
  int i = 0;

  for (final migrationQuery in migrationQueries) {
    i += 1;
    migrations.add(SqliteMigration(i, (tx) async {
      await tx.execute(migrationQuery);
    }));
  }

  return migrations;
}

final migrations = migrate();
