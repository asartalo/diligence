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
];
