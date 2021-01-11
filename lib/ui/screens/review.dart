import 'package:diligence/services/review_data/review_data_bloc.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/ui/components/data/easy_pie_chart.dart';
import 'package:diligence/ui/components/typography/data_title.dart';
import 'package:diligence/ui/layout/gutter.dart';
import 'package:diligence/ui/screens/review/main_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../components/common_screen.dart';
import '../components/easy_card.dart';
import '../components/typography/page_title.dart';
import '../layout/padded_section.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({@required this.title});

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
      children: const [
        Center(
          child: CircularProgressIndicator.adaptive(),
        ),
      ],
    );
  }

  Widget renderContents(BuildContext context, ReviewSummaryData summaryData) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 10.0),
        child: Column(
          children: [
            const PageTitle('Today’s Summary'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: withGutter(
                [
                  Expanded(
                    flex: 6,
                    child: _main(summaryData, theme),
                  ),
                  Expanded(
                    flex: 4,
                    child: _aside(summaryData, theme),
                  ),
                ],
                10.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _main(ReviewSummaryData summaryData, ThemeData theme) {
    return Column(
      children: withGutter(
        [
          MainSummarySection(summaryData: summaryData),
          EasyCard(
            children: [
              const DataTitle('What Happened Today'),
              const PaddedSection(
                child: TextField(
                  minLines: 2,
                  maxLines: null,
                ),
              ),
              PaddedSection(
                child: FlatButton(
                  color: theme.primaryColor,
                  textColor: Colors.white,
                  onPressed: () {},
                  child: const Text('Save Log'),
                ),
              ),
            ],
          ),
        ],
        10.0,
      ),
    );
  }

  Widget _aside(ReviewSummaryData summaryData, ThemeData theme) {
    final tasks = [
      'Rough design 45mins',
      'My goal is to find inspiration, how to layout statistics and journal',
      'Let us call it Daily Notes',
      'Model and what the structure should be',
      'Write DB migration',
    ];

    return EasyCard(
      align: EasyCard.alignLeft,
      children: [
        const DataTitle('Completed Tasks'),
        const SizedBox(
          height: 300,
          width: 600,
          child: Center(
            child: EasyPieChart(
              {
                'Life Goals': 8,
                'Work': 13,
                'Projects': 17,
                'Distractions': 31,
              },
              radius: 120,
            ),
          ),
        ),
        const SizedBox(height: 20.0),
        Column(
          children: _completedTasks(tasks),
        ),
      ],
    );
  }

  List<Widget> _completedTasks(List<String> tasks) {
    return tasks
        .map(
          (String name) => ListTile(
            title: Text(name),
            leading: const Icon(Icons.check),
          ),
        )
        .toList();
  }
}
