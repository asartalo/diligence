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
