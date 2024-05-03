import 'package:flutter/material.dart';

import '../../models/notices/notice.dart';
import '../../services/notices/notice_queue.dart';
import '../join_widgets.dart';
import 'keys.dart' as keys;
import 'notice_item.dart';

class NoticeArea extends StatefulWidget {
  final NoticeQueue noticeQueue;

  const NoticeArea({super.key, required this.noticeQueue});

  @override
  State<NoticeArea> createState() => _NoticeAreaState();
}

class _NoticeAreaState extends State<NoticeArea> {
  late Stream<Notice> noticeStream;
  List<Notice> notices = [];

  NoticeQueue get noticeQueue => widget.noticeQueue;

  @override
  void initState() {
    super.initState();
    noticeQueue.stream.listen(handleUpdateChannel);
    noticeQueue.getNotices().then(handleUpdateChannel);
  }

  void handleUpdateChannel(NoticeList data) {
    if (!context.mounted) return;
    setState(() {
      notices = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keys.noticeArea,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 4.0),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: renderNotices(),
      ),
    );
  }

  List<Widget> renderNotices() {
    return joinWidgets(
      notices,
      delimeter: const Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Divider(color: Colors.black26),
      ),
      builder: (notice) => NoticeItem(
        notice: notice,
        onDismiss: () {
          noticeQueue.dismissNotice(notice);
        },
      ),
    );
  }
}
