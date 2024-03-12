import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../components/clock_wrap.dart';
import '../../components/common_screen.dart';

class HomePage extends StatelessWidget {
  final timeFormat = DateFormat.jm();
  final dateFormat = DateFormat('EEEE, MMMM d, y');

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hourStyle = theme.textTheme.headlineLarge!.merge(
      const TextStyle(
        fontSize: 112.0,
        fontWeight: FontWeight.w200,
      ),
    );
    final welcomeStyle = theme.textTheme.headlineLarge!.merge(
      const TextStyle(
        fontSize: 64.0,
        fontWeight: FontWeight.w300,
      ),
    );
    final buttonStyle = FilledButton.styleFrom(
      minimumSize: const Size(64.0, 64.0),
    );

    return CommonScreen(
      title: 'Diligence',
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Center(
          child: ClockWrap(
            builder: (time) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hello!', style: welcomeStyle),
                const SizedBox(height: 32.0),
                Text(
                  timeFormat.format(time),
                  style: hourStyle,
                ),
                Text(
                  dateFormat.format(time),
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/tasks');
                      },
                      style: buttonStyle,
                      child: const Text('Organize Tasks'),
                    ),
                    const SizedBox(width: 16.0),
                    FilledButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/focus');
                      },
                      style: buttonStyle,
                      child: const Text('Focus'),
                    ),
                  ],
                ),
                const SizedBox(height: 64.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
