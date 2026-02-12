part of 'study_achievement_bloc.dart';

sealed class StudyAchievementState extends Equatable {
  const StudyAchievementState();

  @override
  List<Object> get props => [];
}

final class StudyAchievementInitial extends StudyAchievementState {}

final class StudyAchievementLoading extends StudyAchievementState {}

final class StudyAchievementLoaded extends StudyAchievementState {
  final List<Lecture> lectureWeeks;
  final List<StudyAchievement> studyAchievements;
  final List<Assignment> assignments;

  const StudyAchievementLoaded({
    required this.lectureWeeks,
    required this.studyAchievements,
    required this.assignments,
  });

  @override
  List<Object> get props => [lectureWeeks, studyAchievements, assignments];

  @override
  String toString() =>
      "${lectureWeeks.length} lecture lodaded and ${studyAchievements.length} study achievements loaded and ${assignments.length} assignment loaded";
}

final class StudyAchievementLoadFailed extends StudyAchievementState {}
