part of 'percentage_score_bloc.dart';

sealed class PercentageScoreEvent extends Equatable {
  const PercentageScoreEvent();

  @override
  List<Object> get props => [];
}

class GetPercentageScoreScore extends PercentageScoreEvent {
  final String masterActivityId;

  const GetPercentageScoreScore({
    required this.masterActivityId,
  });

  @override
  List<Object> get props => [masterActivityId];

  @override
  String toString() =>
      "GetPercentageScoreScore {masterActivityId: $masterActivityId}";
}
