import 'package:flutter/material.dart';

class Breadcrumb extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const Breadcrumb(this.label, {super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
