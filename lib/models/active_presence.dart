class ActivePresence {
  final Kul kul;
  final bool sudahPresensi;

  ActivePresence({
    required this.kul,
    required this.sudahPresensi,
  });

  factory ActivePresence.fromJson(Map<String, dynamic> json) {
    return ActivePresence(
      kul: Kul.fromJson(json['kul']),
      sudahPresensi: json['sudah_presensi'] ?? false,
    );
  }

  bool get isHabisWaktu {
    if (sudahPresensi) return false;
    if (kul.presenceLimit.isEmpty) return false;
    try {
      final limit = DateTime.parse(kul.presenceLimit);
      return DateTime.now().toUtc().isAfter(limit);
    } catch (e) {
      return false;
    }
  }
}

class Kul {
  final String academicPeriodId;
  final String subjectId;
  final String majorId;
  final String lecturerId;
  final String subjectClass;
  final String lectureSchedule;
  final String lectureType;
  final int subjectCredit;
  final String hourId;
  final String materialRealization;
  final String lectureLink;
  final String entryTime;
  final int approvalStatus;
  final int weekId;
  final int timeRealization;
  final bool timeSuitability;
  final bool materialSuitability;
  final String materialLink;
  final String lectureId;
  final String presenceLimit;
  final int presenceStudent;
  final String linkMeet;
  final String linkRecord;
  final int collegeType;
  final String collegeTypeName;
  final String timeStart;
  final String timeEnd;
  final String lectureTypeName;
  final String subjectName;

  Kul({
    required this.academicPeriodId,
    required this.subjectId,
    required this.majorId,
    required this.lecturerId,
    required this.subjectClass,
    required this.lectureSchedule,
    required this.lectureType,
    required this.subjectCredit,
    required this.hourId,
    required this.materialRealization,
    required this.lectureLink,
    required this.entryTime,
    required this.approvalStatus,
    required this.weekId,
    required this.timeRealization,
    required this.timeSuitability,
    required this.materialSuitability,
    required this.materialLink,
    required this.lectureId,
    required this.presenceLimit,
    required this.presenceStudent,
    required this.linkMeet,
    required this.linkRecord,
    required this.collegeType,
    required this.collegeTypeName,
    required this.timeStart,
    required this.timeEnd,
    required this.lectureTypeName,
    required this.subjectName,
  });

  factory Kul.fromJson(Map<String, dynamic> json) {
    return Kul(
      academicPeriodId: json['academic_period_id'] ?? "",
      subjectId: json['subject_id'] ?? "",
      majorId: json['major_id'] ?? "",
      lecturerId: json['lecturer_id'] ?? "",
      subjectClass: json['subject_class'] ?? "",
      lectureSchedule: json['lecture_schedule'] ?? "",
      lectureType: json['lecture_type'] ?? "",
      subjectCredit: json['subject_credit'] ?? 0,
      hourId: json['hour_id'] ?? "",
      materialRealization: json['material_realization'] ?? "",
      lectureLink: json['lecture_link'] ?? "",
      entryTime: json['entry_time'] ?? "",
      approvalStatus: json['approval_status'] ?? 0,
      weekId: json['week_id'] ?? 0,
      timeRealization: json['time_realization'] ?? 0,
      timeSuitability: json['time_suitability'] ?? false,
      materialSuitability: json['material_suitability'] ?? false,
      materialLink: json['material_link'] ?? "",
      lectureId: json['lecture_id'] ?? "",
      presenceLimit: json['presence_limit'] ?? "",
      presenceStudent: json['presence_student'] ?? 0,
      linkMeet: json['link_meet'] ?? "",
      linkRecord: json['link_record'] ?? "",
      collegeType: json['college_type'] ?? 0,
      collegeTypeName: json['college_type_name'] ?? "",
      timeStart: json['time_start'] ?? "",
      timeEnd: json['time_end'] ?? "",
      lectureTypeName: json['lecture_type_name'] ?? "",
      subjectName: json['subject_name'] ?? "",
    );
  }
}
