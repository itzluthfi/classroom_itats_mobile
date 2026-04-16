class Subject {
  String subjectClass;
  int subjectCredits;
  String subjectId;
  String majorId;
  String majorName;
  String academicPeriodId;
  String lecturerId;
  String subjectName;
  int totalStudent;
  String activityMasterId;
  // String day;
  // String timeStart;
  // String timeEnd;
  String lecturerName;
  List<Map<String, dynamic>> subjectSchedule;

  Subject({
    required this.subjectClass,
    required this.subjectCredits,
    required this.subjectId,
    required this.majorName,
    required this.majorId,
    required this.academicPeriodId,
    required this.lecturerId,
    required this.subjectName,
    required this.totalStudent,
    required this.activityMasterId,
    required this.lecturerName,
    required this.subjectSchedule,
  });

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        subjectClass: json["subject_class"] ?? "",
        subjectCredits: json["subject_credit"] ?? 0,
        subjectId: json["subject_id"] ?? "",
        majorId: json["major_id"] ?? "",
        majorName: json["major_name"] ?? "",
        academicPeriodId: json["academic_period_id"] ?? "",
        lecturerId: json["lecturer_id"] ?? "",
        subjectName: json["subject_name"] ?? "",
        totalStudent: json["total_student"] ?? 0,
        activityMasterId: json["activity_master_id"] ?? "",
        lecturerName: json["lecturer_name"] ?? "",
        subjectSchedule: json["subject_schedules"] != null
            ? (json["subject_schedules"] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList()
            : <Map<String, dynamic>>[
                {
                  "day": json["day"] ?? "",
                  "time_start": json["time_start"] ?? "",
                  "time_end": json["time_end"] ?? "",
                  "subject_type": json["subject_type"] ?? "",
                }
              ],
      );
}

class SubjectReport {
  String subjectClass;
  int subjectCredits;
  String subjectId;
  String majorId;
  String majorName;
  String academicPeriodId;
  String lecturerId;
  String subjectName;
  int totalStudent;
  String activityMasterId;
  String day;
  String timeStart;
  String timeEnd;
  String lecturerName;
  String hourId;
  String collegeType;
  String roomId;

  SubjectReport({
    required this.subjectClass,
    required this.subjectCredits,
    required this.subjectId,
    required this.majorName,
    required this.majorId,
    required this.academicPeriodId,
    required this.lecturerId,
    required this.subjectName,
    required this.totalStudent,
    required this.activityMasterId,
    required this.lecturerName,
    required this.day,
    required this.timeStart,
    required this.timeEnd,
    required this.hourId,
    required this.collegeType,
    required this.roomId,
  });

  factory SubjectReport.fromJson(Map<String, dynamic> json) => SubjectReport(
        subjectClass: json["subject_class"],
        subjectCredits: json["subject_credit"],
        subjectId: json["subject_id"],
        majorId: json["major_id"],
        majorName: json["major_name"],
        academicPeriodId: json["academic_period_id"],
        lecturerId: json["lecturer_id"],
        subjectName: json["subject_name"],
        totalStudent: json["total_student"] ?? 0,
        activityMasterId: json["activity_master_id"] ?? "",
        lecturerName: json["lecturer_name"] ?? "",
        day: json["day"] ?? "",
        timeStart: json["time_start"] ?? "",
        timeEnd: json["time_end"] ?? "",
        hourId: json["hour_id"] ?? "",
        collegeType: json["subject_type"] ?? "",
        roomId: json["subject_room"] ?? "",
      );
}
