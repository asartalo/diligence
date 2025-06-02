import 'package:flutter/material.dart';

import '../../components/reveal_on_hover.dart';
import 'breadcrumb.dart';

class Breadcrumbs extends StatelessWidget {
  final List<Breadcrumb> crumbs;

  const Breadcrumbs({
    super.key,
    required this.crumbs,
  });

  @override
  Widget build(BuildContext context) {
    return RevealOnHover(
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        children: _crumbs(),
      ),
    );
  }

  List<Widget> _crumbs() {
    final List<Widget> widgets = [];
    for (int i = 0; i < crumbs.length; i++) {
      if (i > 0) {
        widgets.add(const Text(' › '));
      }
      widgets.add(crumbs[i]);
    }

    return widgets;
  }
}
