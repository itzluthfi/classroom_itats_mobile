class Presence {
  String academicPeriodID;
  String subjectID;
  String majorID;
  String subjectClass;
  DateTime collegeSchedule;
  String studentID;
  bool isPresent;
  String collegeType;
  String hourID;
  int weekID;
  bool isOffline;
  int score;

  Presence({
    required this.academicPeriodID,
    required this.subjectID,
    required this.majorID,
    required this.subjectClass,
    required this.collegeSchedule,
    required this.studentID,
    required this.isPresent,
    required this.collegeType,
    required this.hourID,
    required this.weekID,
    required this.isOffline,
    required this.score,
  });

  factory Presence.fromJson(Map<String, dynamic> json) => Presence(
        academicPeriodID: json["academic_period_id"],
        subjectID: json["subject_id"],
        majorID: json["major_id"],
        collegeSchedule:
            DateTime.tryParse(json["college_schedule"]) ?? DateTime(0000),
        subjectClass: json["subject_class"],
        collegeType: json["college_type"],
        isOffline: json["is_offline"],
        isPresent: json["is_present"],
        hourID: json["hour_id"],
        score: json["score"],
        studentID: json["student_id"],
        weekID: json["week_id"],
      );
}

class PresenceQuestion {
  int masterQuestionId;
  String question;
  DateTime createdAt;
  DateTime updatedAt;

  PresenceQuestion({
    required this.masterQuestionId,
    required this.question,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PresenceQuestion.fromJson(Map<String, dynamic> json) =>
      PresenceQuestion(
        masterQuestionId: json["master_question_id"],
        question: json["question"],
        createdAt: DateTime.tryParse(json["created_at"]) ?? DateTime(0000),
        updatedAt: DateTime.tryParse(json["updated_at"]) ?? DateTime(0000),
      );
}
