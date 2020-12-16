part of 'review_data_bloc.dart';

abstract class ReviewDataEvent extends Equatable {
  const ReviewDataEvent();

  @override
  List<Object> get props => [];
}

class ReviewDataRequested extends ReviewDataEvent {
  const ReviewDataRequested();
}
