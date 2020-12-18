import 'package:flutter/material.dart';

class EasyCard extends StatelessWidget {
  final List<Widget> children;

  const EasyCard({@required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Card(
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
