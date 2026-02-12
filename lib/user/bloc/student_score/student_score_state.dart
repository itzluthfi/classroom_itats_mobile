part of 'student_score_bloc.dart';

sealed class StudentScoreState extends Equatable {
  const StudentScoreState();

  @override
  List<Object> get props => [];
}

final class StudentScoreInitial extends StudentScoreState {}

final class StudentScoreLoading extends StudentScoreState {}

final class StudentScoreLoaded extends StudentScoreState {
  final List<StudentScore> studentScores;

  const StudentScoreLoaded({required this.studentScores});

  @override
  List<Object> get props => [studentScores];

  @override
  String toString() => "${studentScores.length} StudentScore Loaded";
}

final class StudentScoreLoadFailed extends StudentScoreState {}
