import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../services/review_data/review_data_bloc.dart';
import '../../services/review_data_service.dart';
import '../components/common_screen.dart';
import '../components/data/easy_pie_chart.dart';
import '../components/easy_card.dart';
import '../components/typography/data_title.dart';
import '../components/typography/page_title.dart';
import '../layout/gutter.dart';
import '../layout/padded_section.dart';
import 'review/main_summary_section.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      title: 'Review',
      child: BlocBuilder<ReviewDataBloc, ReviewDataState>(
        builder: (context, state) {
          final shown = state.maybeSummaryData.choice<Widget>(
            () {
              Provider.of<ReviewDataBloc>(context).requestData();
              return renderSpinner();
            },
            (summaryData) {
              return renderContents(context, summaryData);
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
              const DataTitle('Notes'),
              const PaddedSection(
                child: MarkdownBody(
                  data: '# Foo',
                  key: Key('txtDayLogNotes'),
                ),
              ),
              const PaddedSection(
                child: TextField(
                  key: Key('fieldDayLogNotes'),
                  minLines: 2,
                  maxLines: null,
                ),
              ),
              PaddedSection(
                child: TextButton(
                  key: const Key('btnSaveLog'),
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
