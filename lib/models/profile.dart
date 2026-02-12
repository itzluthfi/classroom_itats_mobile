class Profile {
  String userId;
  String name;
  String photo;
  String phoneNumber;
  String email;
  int presence;
  int totalPresence;
  int assignmentSubmited;
  int totalAssignment;
  List<StudentSubjectPresence> studentSubjectPresences;

  Profile({
    required this.userId,
    required this.name,
    required this.photo,
    required this.phoneNumber,
    required this.email,
    required this.presence,
    required this.totalPresence,
    required this.assignmentSubmited,
    required this.totalAssignment,
    required this.studentSubjectPresences,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userId: json["user_id"],
        name: json["name"],
        photo: json["photo"],
        phoneNumber: json["phone_number"],
        email: json["email"],
        presence: json["presence"],
        totalPresence: json["total_presence"],
        assignmentSubmited: json["assignment_submited"],
        totalAssignment: json["total_assignment"],
        studentSubjectPresences: (json["student_subject_presences"] as List)
            .map((data) => StudentSubjectPresence.fromJson(data))
            .toList(),
      );
}

class StudentSubjectPresence {
  String subjectId;
  String subjectClass;
  String subjectName;
  String activityMasterId;
  int presence;
  int totalPresence;

  StudentSubjectPresence({
    required this.subjectId,
    required this.subjectClass,
    required this.subjectName,
    required this.activityMasterId,
    required this.presence,
    required this.totalPresence,
  });

  factory StudentSubjectPresence.fromJson(Map<String, dynamic> json) =>
      StudentSubjectPresence(
        subjectId: json["subject_id"],
        subjectClass: json["subject_class"],
        subjectName: json["subject_name"],
        activityMasterId: json["activity_master_id"],
        presence: json["presence"],
        totalPresence: json["total_presence"],
      );
}
