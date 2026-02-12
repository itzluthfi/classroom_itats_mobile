class StudentScore {
  String studentId;
  String sudentName;
  String numericScore;
  String alphabeticScore;

  StudentScore({
    required this.studentId,
    required this.sudentName,
    required this.numericScore,
    required this.alphabeticScore,
  });

  factory StudentScore.fromJson(Map<String, dynamic> json) => StudentScore(
        studentId: json["student_id"],
        sudentName: json["student_name"],
        numericScore: json["numeric_score"],
        alphabeticScore: json["alphabetic_score"],
      );
}
