part of 'review_data_bloc.dart';

abstract class ReviewDataState extends Equatable {
  final Maybe<ReviewSummaryData> maybeSummaryData;
  const ReviewDataState(this.maybeSummaryData);

  @override
  List<Object> get props => [maybeSummaryData];

  bool hasData() => false;
}

class ReviewDataInitial extends ReviewDataState {
  ReviewDataInitial() : super(Maybe<ReviewSummaryData>(null));
}

class ReviewDataAvailable extends ReviewDataState {
  ReviewDataAvailable(ReviewSummaryData summaryData)
      : super(Maybe<ReviewSummaryData>(summaryData));

  @override
  bool hasData() => true;
}
