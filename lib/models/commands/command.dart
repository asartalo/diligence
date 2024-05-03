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

import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class Command {
  final String? message;
  final DateTime at;

  const Command({this.message, required this.at});
}

@immutable
abstract class CommandPack<T> extends Command {
  T get payload;
  const CommandPack({super.message, required super.at});
}

@immutable
class NoOpCommand extends Command {
  const NoOpCommand({required super.at});
}
