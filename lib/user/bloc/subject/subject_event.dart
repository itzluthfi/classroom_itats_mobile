part of 'subject_bloc.dart';

sealed class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object> get props => [];
}

class GetSubject extends SubjectEvent {
  final BuildContext context;

  const GetSubject({
    required this.context,
  });

  @override
  List<Object> get props => [context];

  @override
  String toString() => "GetSubject";
}

class FilterButtonPressed extends SubjectEvent {
  final String academicPeriod;
  final String major;
  final BuildContext context;

  const FilterButtonPressed({
    required this.academicPeriod,
    required this.major,
    required this.context,
  });

  @override
  List<Object> get props => [academicPeriod, major, context];

  @override
  String toString() =>
      "GetSubject with academicPeriod $academicPeriod, and major $major";
}

class GetSubjectReport extends SubjectEvent {
  final BuildContext context;

  const GetSubjectReport({
    required this.context,
  });

  @override
  List<Object> get props => [context];

  @override
  String toString() => "GetSubject";
}

class FilterButtonPressedReport extends SubjectEvent {
  final String academicPeriod;
  final String major;
  final BuildContext context;

  const FilterButtonPressedReport({
    required this.academicPeriod,
    required this.major,
    required this.context,
  });

  @override
  List<Object> get props => [academicPeriod, major, context];

  @override
  String toString() =>
      "GetSubject with academicPeriod $academicPeriod, and major $major";
}
