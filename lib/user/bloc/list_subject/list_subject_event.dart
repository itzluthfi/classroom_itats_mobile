part of 'list_subject_bloc.dart';

sealed class ListSubjectEvent extends Equatable {
  const ListSubjectEvent();

  @override
  List<Object> get props => [];
}

class GetLecturerSubject extends ListSubjectEvent {
  final String academicPeriod;
  final String major;

  const GetLecturerSubject({
    required this.academicPeriod,
    required this.major,
  });

  @override
  List<Object> get props => [];

  @override
  String toString() =>
      "GetSubject with academicPeriod $academicPeriod, and major $major";
}
