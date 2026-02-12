import 'dart:convert';

class PercentageScore {
  int totalPercentage;
  List<PercentageScoreDetail> percentageScoreDetails;

  PercentageScore({
    required this.totalPercentage,
    required this.percentageScoreDetails,
  });

  factory PercentageScore.fromJson(Map<String, dynamic> json) =>
      PercentageScore(
        totalPercentage: json["total_percentage"],
        percentageScoreDetails:
            (jsonDecode(jsonEncode(json["percentage_score_detail"])) as List)
                .map((data) => PercentageScoreDetail.fromJson(data))
                .toList(),
      );
}

class PercentageScoreDetail {
  String id;
  String assignmentTitle;
  String assignmentType;
  String weekId;
  int percentage;

  PercentageScoreDetail({
    required this.id,
    required this.assignmentTitle,
    required this.assignmentType,
    required this.weekId,
    required this.percentage,
  });

  factory PercentageScoreDetail.fromJson(Map<String, dynamic> json) =>
      PercentageScoreDetail(
          id: json["id"],
          assignmentTitle: json["assignment_title"],
          assignmentType: json["assignment_type"],
          weekId: json["week_id"],
          percentage: json["percentage"]);
}
