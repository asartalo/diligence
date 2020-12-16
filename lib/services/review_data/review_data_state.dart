part of 'review_data_bloc.dart';

abstract class ReviewDataState extends Equatable {
  final Option<ReviewSummaryData> maybeSummaryData;
  ReviewDataState(this.maybeSummaryData);
  List<Object> get props => [maybeSummaryData];

  bool hasData() => false;
}

class ReviewDataInitial extends ReviewDataState {
  ReviewDataInitial() : super(option<ReviewSummaryData>(false, null));
}

class ReviewDataAvailable extends ReviewDataState {
  ReviewDataAvailable(ReviewSummaryData summaryData)
      : super(option<ReviewSummaryData>(true, summaryData));

  @override
  bool hasData() => true;
}
