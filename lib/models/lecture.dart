class Lecture {
  String? academicPeriodID;
  String? subjectID;
  String? majorID;
  String? lecturerID;
  String? subjectClass;
  DateTime? lectureSchedule;
  String? lectureType;
  int? subjectCredits;
  String? hourID;
  String? material;
  String? lectureLink;
  DateTime? entryTime;
  int? approvalStatus;
  int? weekID;
  int? timeRealization;
  bool? timeSuitability;
  bool? materialSuitability;
  String? materialLink;
  String? lectureID;
  DateTime? presenceLimit;
  int? presenceStudent;
  String? linkMeet;
  String? linkRecord;
  int? collegeType;
  String? collegeTypeName;

  Lecture({
    this.academicPeriodID,
    this.subjectID,
    this.majorID,
    this.lectureID,
    this.subjectClass,
    this.lectureSchedule,
    this.lectureType,
    this.subjectCredits,
    this.hourID,
    this.material,
    this.lectureLink,
    this.entryTime,
    this.approvalStatus,
    this.weekID,
    this.timeRealization,
    this.timeSuitability,
    this.materialSuitability,
    this.materialLink,
    this.lecturerID,
    this.presenceLimit,
    this.presenceStudent,
    this.linkMeet,
    this.linkRecord,
    this.collegeType,
    this.collegeTypeName,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) => Lecture(
        academicPeriodID: json["academic_period_id"],
        subjectID: json["subject_id"],
        majorID: json["major_id"],
        lectureID: json["lecture_id"],
        subjectClass: json["subject_class"],
        lectureSchedule: DateTime.tryParse(json["lecture_schedule"] ?? ""),
        lectureType: json["lecture_type"],
        subjectCredits: int.parse(json["subject_credits"] ?? "0"),
        hourID: json["hour_id"],
        material: json["material_realization"],
        lectureLink: json["lecture_link"],
        entryTime: DateTime.tryParse(json["entry_time"] ?? ""),
        approvalStatus: json["approval_status"],
        weekID: json["week_id"],
        timeRealization: json["time_realization"],
        timeSuitability: json["time_suitability"],
        materialSuitability: json["material_suitability"] ?? false,
        materialLink: json["materal_link"],
        lecturerID: json["lecturer_id"],
        presenceLimit: DateTime.tryParse(json["presence_limit"] ?? ""),
        presenceStudent: json["presence_student"],
        linkMeet: json['link_meet'],
        linkRecord: json['link_record'],
        collegeType: json['college_type'],
        collegeTypeName: json['college_type_name'],
      );
}
