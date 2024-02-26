import 'package:flutter/material.dart';

class TaskItemMenu extends StatelessWidget {
  final List<Widget> menuChildren;
  const TaskItemMenu({super.key, required this.menuChildren});

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: menuChildren,
      style: MenuStyle(
        alignment: Alignment.bottomLeft,
        // minimumSize: MaterialStateProperty.all(const Size(210, 0)),
        // maximumSize: MaterialStateProperty.all(const Size(210, 200)),
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
