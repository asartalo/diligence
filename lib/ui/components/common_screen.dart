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
      drawer: Builder(builder: (context) => const NavigationDrawer()),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                child: Text('Diligence'),
              ),
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
              ListTile(
                title: const Text('Review'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/review');
                },
              ),
            ],
          ),
        ),
      );
}
