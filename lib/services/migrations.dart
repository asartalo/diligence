// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

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
  'ALTER TABLE tasks ADD COLUMN doneAt INTEGER',

  'ALTER TABLE tasks DROP COLUMN done',

  'ALTER TABLE tasks ADD COLUMN createdAt INTEGER DEFAULT 0',

  'ALTER TABLE tasks ADD COLUMN updatedAt INTEGER DEFAULT 0',

  'ALTER TABLE tasks ADD COLUMN deadlineAt INTEGER',

  'ALTER TABLE tasks ADD COLUMN reminderAt INTEGER',
  '''
  CREATE TABLE IF NOT EXISTS jobs (
    uuid TEXT PRIMARY KEY,
    runAt INTEGER NOT NULL,
    type TEXT NOT NULL,
    taskId INTEGER
  )
  ''',
  'CREATE INDEX IF NOT EXISTS jobs_type ON jobs(type)',

  'ALTER TABLE tasks DROP COLUMN reminderAt',

  '''
  CREATE TABLE IF NOT EXISTS reminders (
    taskId INTEGER NOT NULL,
    remindAt INTEGER NOT NULL UNIQUE,
    dismissed INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (taskId, remindAt),
    FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
  )
  ''',
  '''
  CREATE TABLE IF NOT EXISTS notices (
    uuid TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    title TEXT,
    details TEXT,
    taskId INTEGER,
    createdAt INTEGER NOT NULL
  )
  ''',

  'CREATE INDEX runAtIdx On jobs(runAt)',

  // Migrations for adding 'ON DELETE CASCADE' to focusQueue taskId foreign key
  // WARNING: I made a mistake here. I should have cleaned up the focusQueue
  // table before doing the next queries. I should have deleted rows that don't
  // have a corresponding task.
  'ALTER TABLE focusQueue RENAME TO _focusQueue',

  '''
  CREATE TABLE IF NOT EXISTS focusQueue (
    taskId INTEGER PRIMARY KEY,
    position INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (taskId) REFERENCES tasks(id) ON DELETE CASCADE
  )
  ''',

  'INSERT INTO focusQueue SELECT * FROM _focusQueue',

  // Cleanup focusQueue rows that don't have a corresponding task
  '''
  DELETE FROM focusQueue
  WHERE taskId NOT IN (SELECT id FROM tasks)
  ''',

  // Delete the old focusQueue table
  'DROP TABLE _focusQueue',
  // End of migrations for adding 'ON DELETE CASCADE' to focusQueue
];
