class Assignment {
  int assignmentId;
  String activityMasterId;
  int weekId;
  String assignmentTitle;
  String description;
  DateTime dueDate;
  String jNilId;
  DateTime createdAt;
  DateTime updatedAt;
  String fileLink;
  String fileName;
  bool isShow;
  double realPrercentage;
  String subjectClass;
  String subjectName;
  String jNilDesc;
  int totalSubmited;

  Assignment({
    required this.assignmentId,
    required this.activityMasterId,
    required this.weekId,
    required this.assignmentTitle,
    required this.description,
    required this.dueDate,
    required this.jNilId,
    required this.createdAt,
    required this.updatedAt,
    required this.fileLink,
    required this.fileName,
    required this.isShow,
    required this.realPrercentage,
    required this.subjectClass,
    required this.subjectName,
    required this.jNilDesc,
    required this.totalSubmited,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) => Assignment(
        assignmentId: json["assignment_id"],
        activityMasterId: json["activity_master_id"],
        weekId: json["week_id"],
        assignmentTitle: json["assignment_title"],
        description: json["description"],
        dueDate: DateTime.parse(json["due_date"]),
        jNilId: json["j_nil_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        fileLink: json["file_link"],
        fileName: json["file_name"],
        isShow: json["is_show"],
        realPrercentage: double.parse(json["real_prercentage"].toString()),
        subjectClass: json["subject_class"],
        subjectName: json["subject_name"],
        jNilDesc: json["j_nil_desc"],
        totalSubmited: json["total_submited"],
      );
}

class StudentAssignmentScore {
  int assignmentSubmissionId;
  double score;
  String studentId;
  double finalScore;
  int assignmentId;
  String assignmentTitle;

  StudentAssignmentScore({
    required this.assignmentSubmissionId,
    required this.score,
    required this.studentId,
    required this.finalScore,
    required this.assignmentId,
    required this.assignmentTitle,
  });

  factory StudentAssignmentScore.fromJson(Map<String, dynamic> json) =>
      StudentAssignmentScore(
        assignmentSubmissionId: json["assignment_submission_id"],
        score: double.parse(json["score"].toString()),
        studentId: json["student_id"],
        finalScore: double.parse(json["final_score"].toString()),
        assignmentId: json["assignment_id"],
        assignmentTitle: json["assignment_title"],
      );
}

class StudentAssignmentSubmission {
  int assignmentSubmissionId;
  String assignmentFile;
  String assignmentLink;
  String note;
  double score;
  String studentId;
  int assignmentId;
  DateTime createdAt;
  DateTime updatedAt;
  double finalScore;

  StudentAssignmentSubmission({
    required this.assignmentSubmissionId,
    required this.assignmentFile,
    required this.assignmentLink,
    required this.note,
    required this.score,
    required this.studentId,
    required this.assignmentId,
    required this.createdAt,
    required this.updatedAt,
    required this.finalScore,
  });

  factory StudentAssignmentSubmission.fromJson(Map<String, dynamic> json) =>
      StudentAssignmentSubmission(
        assignmentSubmissionId: json["assignment_submission_id"],
        score: double.parse(json["score"].toString()),
        studentId: json["student_id"],
        finalScore: double.parse(json["final_score"].toString()),
        assignmentId: json["assignment_id"],
        assignmentFile: json["assignment_file"],
        assignmentLink: json["assignment_link"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        note: json["note"],
      );
}

class StudentAssignmentJoin {
  int assignmentId;
  String activityMasterId;
  int weekId;
  String assignmentTitle;
  String description;
  DateTime dueDate;
  String jNilId;
  String fileLink;
  String fileName;

  int assignmentSubmissionId;
  String assignmentFile;
  String assignmentLink;
  String note;
  String studentId;
  DateTime createdAt;
  DateTime updatedAt;

  StudentAssignmentJoin({
    required this.assignmentId,
    required this.activityMasterId,
    required this.weekId,
    required this.assignmentTitle,
    required this.description,
    required this.dueDate,
    required this.jNilId,
    required this.fileLink,
    required this.fileName,
    required this.assignmentSubmissionId,
    required this.assignmentFile,
    required this.assignmentLink,
    required this.note,
    required this.studentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StudentAssignmentJoin.fromJson(Map<String, dynamic> json) =>
      StudentAssignmentJoin(
        assignmentId: json["assignment_id"],
        activityMasterId: json["activity_master_id"],
        weekId: json["week_id"],
        assignmentTitle: json["assignment_title"],
        description: json["description"],
        dueDate: DateTime.parse(json["due_date"]),
        jNilId: json["j_nil_id"],
        fileLink: json["file_link"],
        fileName: json["file_name"],
        assignmentSubmissionId: json["assignment_submission_id"],
        studentId: json["student_id"],
        assignmentFile: json["assignment_file"],
        assignmentLink: json["assignment_link"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        note: json["note"],
      );
}
