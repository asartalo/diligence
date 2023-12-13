import 'package:flutter/widgets.dart';

import '../../components/common_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonScreen(
      title: 'Home',
      child: Column(
        children: [
          Text('Home'),
        ],
      ),
    );
  }
}
