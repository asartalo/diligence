import 'package:diligence/ui/theme.dart';
import 'package:flutter/material.dart';

import '../components/app_bar.dart';
import '../components/data/single_number.dart';
import '../components/data/single_number_horizontal.dart';
import '../components/easy_card.dart';
import '../components/typography/page_title.dart';
import '../components/typography/section_title.dart';
import '../layout/even_row.dart';
import '../layout/padded_section.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var diligenceTheme = DiligenceTheme.fromTheme(theme);
    return Scaffold(
      appBar: appBar(context, 'Review'),
      backgroundColor: theme.backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                PageTitle('Today’s Summary'),
                EasyCard(
                  children: [
                    EvenRow(
                      children: [
                        SingleNumberDataPoint(
                          title: 'Completed Tasks',
                          number: 23,
                        ),
                        SingleNumberDataPoint(
                          title: 'Overdue',
                          number: 2,
                        ),
                        SingleNumberDataPoint(
                          title: 'New Tasks',
                          number: 15,
                        ),
                      ],
                    ),
                    EvenRow(
                      children: [
                        SingleNumberDataPointHorizontal(
                          title: 'Daily net tasks',
                          caption: 'completed + destroyed - added',
                          number: 40,
                        ),
                        SingleNumberDataPointHorizontal(
                          title: 'Task Completion Rate',
                          caption: 'daily',
                          number: 1.3,
                        ),
                      ],
                    ),
                  ],
                ),
                EasyCard(
                  children: [
                    SectionTitle('What Happened Today'),
                    PaddedSection(
                      child: TextField(
                        minLines: 1,
                        maxLines: null,
                      ),
                    ),
                    PaddedSection(
                      child: FlatButton(
                        child: Text('Save Log'),
                        color: theme.primaryColor,
                        textColor: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
