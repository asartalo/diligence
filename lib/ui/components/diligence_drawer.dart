import 'package:flutter/material.dart';

import '../../diligence_config.dart';
import 'app_link.dart';
import 'keys.dart' as keys;

List<AppLink> _getLinks(DiligenceConfig config) {
  return [
    const AppLink(
      '/',
      'Home',
      keys.drawerLinkHome,
    ),
    const AppLink(
      '/tasks',
      'Tasks',
      keys.drawerLinkTasks,
    ),
    const AppLink(
      '/focus',
      'Focus',
      keys.drawerLinkFocus,
    ),
    if (config.showReviewPage) ...[
      const AppLink(
        '/review',
        'Review Link',
        keys.drawerLinkReview,
      ),
    ],
  ];
}

class DiligenceDrawer extends StatelessWidget {
  final List<AppLink> _links;

  DiligenceDrawer({super.key, required DiligenceConfig config})
      : _links = _getLinks(config);

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
