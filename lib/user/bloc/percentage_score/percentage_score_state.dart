part of 'percentage_score_bloc.dart';

sealed class PercentageScoreState extends Equatable {
  const PercentageScoreState();

  @override
  List<Object> get props => [];
}

final class PercentageScoreInitial extends PercentageScoreState {}

final class PercentageScoreLoading extends PercentageScoreState {}

final class PercentageScoreLoaded extends PercentageScoreState {
  final PercentageScore percentageScores;

  const PercentageScoreLoaded({required this.percentageScores});

  @override
  List<Object> get props => [percentageScores];

  @override
  String toString() => "PercentageScore Loaded";
}

final class PercentageScoreLoadFailed extends PercentageScoreState {}
