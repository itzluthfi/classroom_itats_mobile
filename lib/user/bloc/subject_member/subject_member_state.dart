part of 'subject_member_bloc.dart';

sealed class SubjectMemberState extends Equatable {
  const SubjectMemberState();

  @override
  List<Object> get props => [];
}

final class SubjectMemberInitial extends SubjectMemberState {}

final class SubjectMemberLoading extends SubjectMemberState {}

final class SubjectMemberLoaded extends SubjectMemberState {
  final List<SubjectMember> subjectMembers;

  const SubjectMemberLoaded({required this.subjectMembers});

  @override
  List<Object> get props => [subjectMembers];

  @override
  String toString() => "${subjectMembers.length} Subject Member Loaded";
}

final class SubjectMemberLoadFailed extends SubjectMemberState {}
