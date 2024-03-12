import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../diligence_config.dart';
import './app_bar.dart';
import 'diligence_drawer.dart';

class CommonScreen extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const CommonScreen({
    super.key,
    required this.title,
    required this.child,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Hero(
          tag: 'appbar',
          child: Builder(builder: (context) => appBar(context, title)),
        ),
      ),
      backgroundColor: theme.colorScheme.background,
      body: Builder(
        builder: (BuildContext context) => child,
      ),
      floatingActionButton: floatingActionButton,
      drawer: Builder(
        builder: (context) => DiligenceDrawer(
          config: Provider.of<DiligenceConfig>(context),
        ),
      ),
    );
  }
}
