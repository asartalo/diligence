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
