class Week {
  int weekId;
  int weekNumber;
  bool isActive;
  bool isTest;
  String note;

  Week({
    required this.weekId,
    required this.weekNumber,
    required this.isActive,
    required this.isTest,
    required this.note,
  });

  factory Week.fromJson(Map<String, dynamic> json) => Week(
        weekId: json["week_id"],
        weekNumber: json["week_number"],
        isActive: json["isactive"],
        isTest: json["isactive"],
        note: json["note"],
      );
}
