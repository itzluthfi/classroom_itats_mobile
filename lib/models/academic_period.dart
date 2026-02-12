class AcademicPeriod {
  String academicPeriodId;
  String oddEven;
  String curriculumId;
  String academicPeriodDecription;
  int yearStart;
  int yearEnd;
  int academicPeriodIndex;
  bool isActive;

  AcademicPeriod({
    required this.academicPeriodId,
    required this.oddEven,
    required this.curriculumId,
    required this.academicPeriodDecription,
    required this.yearStart,
    required this.yearEnd,
    required this.academicPeriodIndex,
    required this.isActive,
  });

  factory AcademicPeriod.fromJson(Map<String, dynamic> json) => AcademicPeriod(
        academicPeriodId: json["academic_period_id"],
        oddEven: json["odd_even"],
        curriculumId: json["curriculum_id"],
        academicPeriodDecription: json["academic_period_description"],
        yearStart: json["year_start"],
        yearEnd: json["year_end"],
        academicPeriodIndex: json["academic_period_index"],
        isActive: json["is_active"],
      );
}
