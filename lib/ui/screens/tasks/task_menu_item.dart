import 'package:flutter/material.dart';

class TaskMenuItem extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  final String label;

  const TaskMenuItem({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return MenuItemButton(
      leadingIcon: Icon(icon),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
