import 'package:flutter/widgets.dart';

import '../../components/common_screen.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonScreen(
      title: 'Focus',
      child: Column(
        children: [
          Text('Focus'),
        ],
      ),
    );
  }
}
