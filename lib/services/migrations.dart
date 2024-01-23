const migrationQueries = [
  '''
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY,
    uid TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    details TEXT,
    parentId INTEGER,
    position INTEGER NOT NULL DEFAULT 0,
    done INTEGER NOT NULL DEFAULT 0,
    expanded INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (parentId) REFERENCES tasks(id)
  )
  ''',
];
