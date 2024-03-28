// Diligence - A Task Management App
//
// Copyright (C) 2024 Wayne Duran <asartalo@gmail.com>
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// this program. If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../utils/maybe.dart';
import '../review_data_service.dart';
import '../side_effects.dart';

part 'review_data_event.dart';
part 'review_data_state.dart';

class ReviewDataBloc extends Bloc<ReviewDataEvent, ReviewDataState> {
  final ReviewDataService dataService;
  final SideEffects sideEffects;
  ReviewDataBloc(this.dataService, {required this.sideEffects})
      : super(ReviewDataInitial()) {
    on<ReviewDataRequested>((_, emit) async {
      emit(await _dataRequested());
    });
  }

  void requestData() {
    add(const ReviewDataRequested());
  }

  Future<ReviewDataState> _dataRequested() async {
    final summaryData = await dataService.getSummaryData(sideEffects.now());

    return ReviewDataAvailable(summaryData);
  }
}
