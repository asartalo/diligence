import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/ui/screens/review/main_summary_section.dart';
import 'package:flutter/material.dart';

import '../components/common_screen.dart';
import '../components/easy_card.dart';
import '../components/typography/page_title.dart';
import '../components/typography/section_title.dart';
import '../layout/padded_section.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage({@required this.title});

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
  Future<ReviewSummaryData> _summaryData = ReviewDataService().getSummaryData();

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Review',
      child: FutureBuilder<ReviewSummaryData>(
        future: _summaryData,
        builder: (
          BuildContext context,
          AsyncSnapshot<ReviewSummaryData> snapshot,
        ) {
          return snapshot.hasData
              ? renderContents(context, snapshot.data)
              : renderSpinner();
        },
      ),
    );
  }

  Widget renderSpinner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ],
    );
  }

  Widget renderContents(BuildContext context, ReviewSummaryData summaryData) {
    var theme = Theme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1000.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PageTitle('Today’s Summary'),
              MainSummarySection(summaryData: summaryData),
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
    );
  }
}
