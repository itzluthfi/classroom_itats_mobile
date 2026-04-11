part of 'study_achievement_bloc.dart';

sealed class StudyAchievementEvent extends Equatable {
  const StudyAchievementEvent();

  @override
  List<Object> get props => [];
}

class GetStudyAchievement extends StudyAchievementEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudyAchievement({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudyAchievement {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}
