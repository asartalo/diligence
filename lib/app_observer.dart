import 'package:flutter/widgets.dart';

import 'utils/logger.dart';

class AppObserver extends StatefulWidget {
  final Logger logger;

  final Widget child;

  const AppObserver({super.key, required this.logger, required this.child});

  @override
  State<AppObserver> createState() => _AppObserverState();
}

class _AppObserverState extends State<AppObserver> with WidgetsBindingObserver {
  Logger get logger => widget.logger;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger.trace('AppObserver: AppLifecycleState changed to $state');
  }
}
