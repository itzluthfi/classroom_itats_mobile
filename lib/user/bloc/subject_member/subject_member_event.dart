part of 'subject_member_bloc.dart';

sealed class SubjectMemberEvent extends Equatable {
  const SubjectMemberEvent();

  @override
  List<Object> get props => [];
}

class GetSubjectMember extends SubjectMemberEvent {
  final String academicPeriodId;
  final String subjectId;
  final String subjectClass;
  final String majorId;

  const GetSubjectMember({
    required this.academicPeriodId,
    required this.subjectId,
    required this.subjectClass,
    required this.majorId,
  });

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      "GetSubjectMember{{academicPeriod: $academicPeriodId, subjectId: $subjectId, subjectClass: $subjectClass, majorId: $majorId}}";
}
