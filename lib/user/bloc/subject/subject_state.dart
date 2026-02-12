part of 'subject_bloc.dart';

sealed class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object> get props => [];
}

final class SubjectInitial extends SubjectState {}

final class SubjectLoading extends SubjectState {}

final class SubjectLoaded extends SubjectState {
  final List<Widget> data;
  final List<Subject> subjects;
  final List<SubjectReport> subjectReports;

  const SubjectLoaded({
    required this.data,
    required this.subjects,
    required this.subjectReports,
  });

  @override
  List<Object> get props => [data, subjects];

  @override
  String toString() =>
      "${subjects.isNotEmpty ? "${subjects.length} Subject Loaded" : ""} ${subjectReports.isNotEmpty ? "${subjectReports.length} Subject Loaded" : ""}";
}

final class SubjectLoadFailed extends SubjectState {}
