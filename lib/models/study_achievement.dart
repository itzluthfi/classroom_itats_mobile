class StudyAchievement {
  int studyAchievementId;
  String subjectId;
  String studyAchievementDescription;
  String lecturerId;
  int majorPlanId;
  int studyPlanId;
  String majorId;
  String academicPeriodId;
  String subjectClass;
  String studyPlanDescription;
  String note;
  String code;
  int studyPlanMappingId;
  int weekId;
  String lectureId;
  String linkMeet;
  String linkRecord;
  int collegeType;

  StudyAchievement({
    required this.studyAchievementId,
    required this.subjectId,
    required this.studyAchievementDescription,
    required this.lecturerId,
    required this.majorPlanId,
    required this.studyPlanId,
    required this.majorId,
    required this.academicPeriodId,
    required this.subjectClass,
    required this.studyPlanDescription,
    required this.note,
    required this.code,
    required this.studyPlanMappingId,
    required this.weekId,
    required this.lectureId,
    required this.linkMeet,
    required this.linkRecord,
    required this.collegeType,
  });

  factory StudyAchievement.fromJson(Map<String, dynamic> json) =>
      StudyAchievement(
        studyAchievementId: json["study_achievement_id"],
        subjectId: json["subject_id"],
        studyAchievementDescription: json["study_achievement_description"],
        lecturerId: json["lecturer_id"],
        majorPlanId: json["major_plan_id"],
        studyPlanId: json["study_plan_id"],
        majorId: json["major_id"],
        academicPeriodId: json["academic_period_id"],
        subjectClass: json["subject_class"],
        studyPlanDescription: json["study_plan_description"],
        note: json["note"],
        code: json["code"],
        studyPlanMappingId: json["study_plan_mapping_id"],
        weekId: json["week_id"],
        lectureId: json["lecture_id"],
        linkMeet: json["link_meet"],
        linkRecord: json["link_record"],
        collegeType: json["college_type"],
      );
}
