part of 'presence_bloc.dart';

sealed class PresenceEvent extends Equatable {
  const PresenceEvent();

  @override
  List<Object> get props => [];
}

class GetStudentPresence extends PresenceEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudentPresence({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudentPresence {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}

class GetPresenceQuestion extends PresenceEvent {
  final String academicPeriod;

  const GetPresenceQuestion({
    required this.academicPeriod,
  });

  @override
  List<Object> get props => [academicPeriod];

  @override
  String toString() => "GetStudentPresence {academicPeriod: $academicPeriod}";
}

class SetStudentPresence extends PresenceEvent {
  final Object studentPresence;

  const SetStudentPresence({required this.studentPresence});

  @override
  List<Object> get props => [studentPresence];

  @override
  String toString() => "SetStudentPresence {studentPresence: $studentPresence}";
}
