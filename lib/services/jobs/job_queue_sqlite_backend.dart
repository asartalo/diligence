// Diligence - A Task Management App
//
// Copyright (C) 2025 Wayne Duran <asartalo@gmail.com>
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

import 'package:sqlite_async/sqlite_async.dart';

import '../diligent/sqlite_backend_common.dart';

class JobQueueSqliteBackend {
  final SqliteDatabase _db;
  final WriteTxScopeFn _writeTxFn;
  final ReadTxScopeFn _readTxFn;

  JobQueueSqliteBackend({
    required SqliteDatabase db,
    required WriteTxScopeFn writeTxFn,
    required ReadTxScopeFn readTxFn,
  }) : _db = db,
       _writeTxFn = writeTxFn,
       _readTxFn = readTxFn;

  Future<T> writeScoped<T>(WriteScopedFn<T> fn) {
    return _db.writeTransaction((tx) => fn(_writeTxFn(tx)));
  }

  Future<T> readScoped<T>(ReadScopedFn<T> fn) {
    return _db.readTransaction((tx) => fn(_readTxFn(tx)));
  }
}
