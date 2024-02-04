import 'package:flutter/material.dart';

import 'keys.dart' as keys;

class AppLink {
  final String path;
  final String title;
  final Key key;

  const AppLink(this.path, this.title, this.key);
}

const _links = [
  AppLink(
    '/',
    'Home',
    keys.drawerLinkHome,
  ),
  AppLink(
    '/tasks',
    'Tasks',
    keys.drawerLinkTasks,
  ),
  AppLink(
    '/focus',
    'Focus',
    keys.drawerLinkFocus,
  ),
  AppLink(
    '/review',
    'Review Link',
    keys.drawerLinkReview,
  ),
];

class DiligenceDrawer extends StatelessWidget {
  const DiligenceDrawer({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const DrawerHeader(
                child: Text('Diligence'),
              ),
              ..._links.map(
                (link) => ListTile(
                  key: link.key,
                  title: Text(link.title),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed(link.path);
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
