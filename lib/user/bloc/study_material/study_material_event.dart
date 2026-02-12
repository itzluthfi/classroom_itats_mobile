part of 'study_material_bloc.dart';

sealed class StudyMaterialEvent extends Equatable {
  const StudyMaterialEvent();

  @override
  List<Object> get props => [];
}

class GetStudyMaterial extends StudyMaterialEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;
  final int weekId;

  const GetStudyMaterial({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
    required this.weekId,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudyMaterial {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass, weekId: $weekId}";
}

class GetLecturerMaterial extends StudyMaterialEvent {
  const GetLecturerMaterial();

  @override
  List<Object> get props => [];

  @override
  String toString() => "GetLecturerMaterial";
}

class GetLecturerMaterialWithDrowpdownValue extends StudyMaterialEvent {
  final String lectureId;
  const GetLecturerMaterialWithDrowpdownValue({required this.lectureId});

  @override
  List<Object> get props => [lectureId];

  @override
  String toString() => "GetLecturerMaterial{lectureId: $lectureId}";
}

class ClearStateStudyMaterial extends StudyMaterialEvent {}
