part of 'student_score_bloc.dart';

sealed class StudentScoreEvent extends Equatable {
  const StudentScoreEvent();

  @override
  List<Object> get props => [];
}

class GetStudentScore extends StudentScoreEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudentScore({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudentScore {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}
