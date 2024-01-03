const migrationQueries = [
  '''
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    parentId INTEGER,
    position INTEGER NOT NULL DEFAULT 0,
    done INTEGER NOT NULL DEFAULT 0
  )
  ''',
  '''
  ALTER TABLE tasks
    ADD details TEXT;
  ''',
];
