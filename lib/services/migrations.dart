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
  '''
  CREATE TABLE IF NOT EXISTS focusQueue (
    taskId INTEGER PRIMARY KEY,
    position INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (taskId) REFERENCES tasks(id)
  )
  ''',
  // Modify tasks table to add a new datetime column named doneAt
  '''
  ALTER TABLE tasks ADD COLUMN doneAt INTEGER
  ''',

  '''
  ALTER TABLE tasks DROP COLUMN done
  ''',

  'ALTER TABLE tasks ADD COLUMN createdAt INTEGER DEFAULT 0',

  'ALTER TABLE tasks ADD COLUMN updatedAt INTEGER DEFAULT 0',
];
