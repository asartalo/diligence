import 'package:diligence/services/review_data/review_data_bloc.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/ui/screens/review/main_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../components/common_screen.dart';
import '../components/easy_card.dart';
import '../components/typography/page_title.dart';
import '../components/typography/section_title.dart';
import '../layout/padded_section.dart';

class ReviewPage extends StatelessWidget {
  ReviewPage({@required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Review',
      child: BlocBuilder<ReviewDataBloc, ReviewDataState>(
        builder: (context, state) {
          Widget shown;
          state.maybeSummaryData.fold(
            () {
              shown = renderSpinner();
              Provider.of<ReviewDataBloc>(context).requestData();
            },
            (summaryData) {
              shown = renderContents(context, summaryData);
            },
          );
          return shown;
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
