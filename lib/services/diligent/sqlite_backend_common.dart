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

import '../../di/read_tx_scope.dart';
import '../../di/write_tx_scope.dart';

typedef WriteTxScopeFn = WriteTxScope Function(SqliteWriteContext tx);
typedef ReadTxScopeFn = ReadTxScope Function(SqliteReadContext tx);
typedef WriteScopedFn<T> = Future<T> Function(WriteTxScope scope);
typedef ReadScopedFn<T> = Future<T> Function(ReadTxScope scope);
