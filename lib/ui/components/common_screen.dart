import 'package:flutter/material.dart';

import './app_bar.dart';

class CommonScreen extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const CommonScreen({
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: appBar(context, title),
      backgroundColor: theme.colorScheme.background,
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}
