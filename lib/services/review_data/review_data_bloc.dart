import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:diligence/services/review_data_service.dart';
import 'package:diligence/services/side_effects.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'review_data_event.dart';
part 'review_data_state.dart';

class ReviewDataBloc extends Bloc<ReviewDataEvent, ReviewDataState> {
  final ReviewDataService dataService;
  final SideEffects sideEffects;
  ReviewDataBloc(this.dataService, {@required this.sideEffects})
      : super(ReviewDataInitial());

  @override
  Stream<ReviewDataState> mapEventToState(
    ReviewDataEvent event,
  ) async* {
    if (event is ReviewDataRequested) {
      yield* _dataRequested();
    }
  }

  void requestData() {
    add(const ReviewDataRequested());
  }

  Stream<ReviewDataState> _dataRequested() async* {
    final summaryData = await dataService.getSummaryData(sideEffects.now());
    yield ReviewDataAvailable(summaryData);
  }
}
