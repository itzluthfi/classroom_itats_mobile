import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/study_achievement.dart';
import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/study_achievement_repository.dart';
import 'package:equatable/equatable.dart';

part 'study_achievement_event.dart';
part 'study_achievement_state.dart';

class StudyAchievementBloc
    extends Bloc<StudyAchievementEvent, StudyAchievementState> {
  final StudyAchievementRepository studyAchievementRepository;
  final AssignmentRepository assignmentRepository;
  final LectureRepository lectureRepository;

  StudyAchievementBloc(
      {required this.studyAchievementRepository,
      required this.assignmentRepository,
      required this.lectureRepository})
      : super(StudyAchievementInitial()) {
    on<GetStudyAchievement>((event, emit) async {
      emit(StudyAchievementLoading());
      try {
        var lectureWeeks = await lectureRepository.getLectureWeeks(
            event.academicPeriod, event.subjectId, event.subjectClass);

        var studyAchievements =
            await studyAchievementRepository.getStudyAchievement(
                event.academicPeriod, event.subjectId, event.subjectClass);

        var assignments = await assignmentRepository
            .getStudyAssignment(
              event.academicPeriod,
              event.subjectId,
              event.subjectClass,
            );

        emit(StudyAchievementLoaded(
          lectureWeeks: lectureWeeks,
          studyAchievements: studyAchievements,
          assignments: assignments,
        ));
      } catch (e, stackTrace) {
        print("ERROR StudyAchievementBloc: $e\n$stackTrace");
        emit(StudyAchievementLoadFailed());
      }
    });
  }
}
