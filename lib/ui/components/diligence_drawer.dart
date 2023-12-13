import 'package:flutter/material.dart';

import '../keys.dart' as keys;

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
              ListTile(
                key: keys.drawerLinkHome,
                title: const Text('Home'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
              ListTile(
                key: keys.drawerLinkTasks,
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/tasks');
                },
              ),
              ListTile(
                key: keys.drawerLinkReview,
                title: const Text('Review Link'),
                onTap: () {
                  Navigator.of(context).pushReplacementNamed('/review');
                },
              ),
            ],
          ),
        ),
      );
}
