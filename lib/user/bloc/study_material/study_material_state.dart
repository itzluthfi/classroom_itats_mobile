part of 'study_material_bloc.dart';

sealed class StudyMaterialState extends Equatable {
  const StudyMaterialState();

  @override
  List<Object> get props => [];
}

final class StudyMaterialInitial extends StudyMaterialState {}

final class StudyMaterialLoading extends StudyMaterialState {}

final class StudyMaterialLoaded extends StudyMaterialState {
  final List<StudyMaterial> studyMaterials;
  final List<StudyMaterial> selectedMaterials;
  final List<Week> weekMaterials;

  const StudyMaterialLoaded(
      {required this.studyMaterials,
      required this.weekMaterials,
      required this.selectedMaterials});

  @override
  List<Object> get props => [studyMaterials];

  @override
  String toString() =>
      "${studyMaterials.length} study material loaded ${weekMaterials.isNotEmpty ? "${weekMaterials.length} week loaded" : ""} ${selectedMaterials.isNotEmpty ? "${selectedMaterials.length} selected materials" : ""}";
}

final class StudyMaterialLoadFailed extends StudyMaterialState {}
