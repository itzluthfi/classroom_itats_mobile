import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/study_material.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/study_material_repository.dart';
import 'package:equatable/equatable.dart';

part 'study_material_event.dart';
part 'study_material_state.dart';

class StudyMaterialBloc extends Bloc<StudyMaterialEvent, StudyMaterialState> {
  final StudyMaterialRepository studyMaterialRepository;
  final AssignmentRepository assignmentRepository;

  StudyMaterialBloc(
      {required this.studyMaterialRepository,
      required this.assignmentRepository})
      : super(StudyMaterialInitial()) {
    on<GetStudyMaterial>((event, emit) async {
      emit(StudyMaterialLoading());
      try {
        var studyMaterials = await studyMaterialRepository.getStudyMaterial(
          event.academicPeriod,
          event.subjectId,
          event.subjectClass,
          event.weekId,
        );

        emit(StudyMaterialLoaded(
          studyMaterials: studyMaterials,
          weekMaterials: List.empty(),
          selectedMaterials: List.empty(),
        ));
      } catch (e) {
        emit(StudyMaterialLoadFailed());
      }
    });
    on<GetLecturerMaterial>((event, emit) async {
      emit(StudyMaterialLoading());
      try {
        var studyMaterials =
            await studyMaterialRepository.getLecturerMaterials();
        var weekMaterials = await assignmentRepository.getWeekAssignment();

        emit(StudyMaterialLoaded(
          studyMaterials: studyMaterials,
          weekMaterials: weekMaterials,
          selectedMaterials: List.empty(),
        ));
      } catch (e) {
        emit(StudyMaterialLoadFailed());
      }
    });

    on<GetLecturerMaterialWithDrowpdownValue>((event, emit) async {
      emit(StudyMaterialLoading());
      try {
        var studyMaterials =
            await studyMaterialRepository.getLecturerMaterials();
        var selectedMaterials =
            await studyMaterialRepository.getSelectedMaterial(event.lectureId);
        var weekMaterials = await assignmentRepository.getWeekAssignment();

        emit(StudyMaterialLoaded(
          studyMaterials: studyMaterials,
          weekMaterials: weekMaterials,
          selectedMaterials: selectedMaterials,
        ));
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        emit(StudyMaterialLoadFailed());
      }
    });

    on<ClearStateStudyMaterial>((event, emit) {
      emit(StudyMaterialInitial());
    });
  }
}
