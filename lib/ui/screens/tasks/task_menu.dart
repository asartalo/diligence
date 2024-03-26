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

import 'package:flutter/material.dart';

import 'keys.dart' as keys;

class TaskMenu extends StatelessWidget {
  final List<Widget> menuChildren;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const TaskMenu({
    super.key,
    required this.menuChildren,
    this.onClose,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      key: keys.taskMenu,
      menuChildren: menuChildren,
      onClose: onClose,
      onOpen: onOpen,
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        backgroundColor: MaterialStateProperty.all(Colors.white),
      ),
      alignmentOffset: const Offset(-60.0, 0.0),
      builder: (context, controller, child) => IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
    );
  }
}
