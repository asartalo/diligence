import 'package:flutter/material.dart';

import '../../models/notices/notice.dart';
import 'reveal_on_hover.dart';

class NoticeItem extends StatelessWidget {
  final Notice notice;
  final VoidCallback onDismiss;

  const NoticeItem({
    super.key,
    required this.notice,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      child: Row(
        children: [
          Text(notice.title, style: const TextStyle(fontSize: 18.0)),
          ...renderDetails(),
          const Spacer(),
          //
          RevealOnHover(
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('DISMISS'),
            ),
          ),
          ...renderActions(),
        ],
      ),
    );
  }

  List<Widget> renderActions() {
    final List<Widget> padding = [const SizedBox(width: 5)];

    return padding +
        notice.actions().map((action) {
          return Padding(
            padding: const EdgeInsets.only(left: 5),
            child: TextButton(
              onPressed: () {
                action.action();
                onDismiss();
              },
              child: Text(action.label.toUpperCase()),
            ),
          );
        }).toList();
  }

  List<Widget> renderDetails() {
    final List<Widget> detailWidgets = [];
    final details = notice.details;
    if (details is String) {
      detailWidgets.add(Text(
        details,
        style: const TextStyle(fontSize: 14.0),
      ));
    }
    return detailWidgets;
  }
}
