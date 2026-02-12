part of 'assignment_bloc.dart';

sealed class AssignmentState extends Equatable {
  const AssignmentState();

  @override
  List<Object> get props => [];
}

final class AssignmentInitial extends AssignmentState {}

final class AssignmentLoading extends AssignmentState {}

final class AssignmentLoaded extends AssignmentState {
  final List<Assignment> assignments;
  final List<StudentAssignmentJoin> assignmentsJoin;
  final List<StudentAssignmentScore> studentAssigmentScores;
  final List<Subject> subjects;
  final List<Week> weekAssignments;
  final List<ScoreType> scoreType;
  final StudentAssignmentSubmission? studentAssignmentSubmission;

  const AssignmentLoaded({
    required this.assignments,
    required this.assignmentsJoin,
    required this.studentAssigmentScores,
    required this.subjects,
    required this.weekAssignments,
    required this.scoreType,
    required this.studentAssignmentSubmission,
  });

  @override
  List<Object> get props => [
        assignments,
        assignmentsJoin,
        studentAssigmentScores,
        subjects,
        weekAssignments,
        scoreType,
        studentAssigmentScores,
      ];

  @override
  String toString() =>
      "${assignments.isNotEmpty ? "${assignments.length} assignment loaded" : ""} ${studentAssigmentScores.isNotEmpty ? "${studentAssigmentScores.length} student assignment score loaded" : ""} ${weekAssignments.isNotEmpty ? "${weekAssignments.length} week assignment loaded" : ""} ${scoreType.isNotEmpty ? "${scoreType.length} score type loaded" : ""} ${subjects.isNotEmpty ? "${subjects.length} subjects type loaded" : ""} ${studentAssignmentSubmission != null ? "Student Assignment Submission loaded" : ""} ${assignmentsJoin.isNotEmpty ? "${assignmentsJoin.length} assignment loaded" : ""}";
}

final class AssignmentLoadFailed extends AssignmentState {}

final class AssignmentFileDownloadLoading extends AssignmentState {}

final class AssignmentFileDownloadSuccess extends AssignmentState {}

final class AssignmentFileDownloadFailed extends AssignmentState {}

final class CreateAssignmentLoading extends AssignmentState {}

final class CreateAssignmentSuccess extends AssignmentState {}

final class CreateAssignmentFailed extends AssignmentState {}
