part of 'list_subject_bloc.dart';

sealed class ListSubjectState extends Equatable {
  const ListSubjectState();

  @override
  List<Object> get props => [];
}

final class ListSubjectInitial extends ListSubjectState {}

final class ListSubjectLoading extends ListSubjectState {}

final class ListSubjectLoaded extends ListSubjectState {
  final List<Subject> subjects;

  const ListSubjectLoaded({required this.subjects});

  @override
  List<Object> get props => [subjects];

  @override
  String toString() => "${subjects.length} Subject Loaded";
}

final class ListSubjectLoadFailed extends ListSubjectState {}
