class Major {
  String majorId;
  String realMajorId;
  String majorName;
  String studyProgramName;

  Major({
    required this.majorId,
    required this.realMajorId,
    required this.majorName,
    required this.studyProgramName,
  });

  factory Major.fromJson(Map<String, dynamic> json) => Major(
        majorId: json["major_id"],
        realMajorId: json["real_major_id"],
        majorName: json["major_name"],
        studyProgramName: json["study_program_name"],
      );
}
