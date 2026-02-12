class ScoreType {
  String scoreTypeId;
  String scoreTypeDesc;
  int scoreWeight;
  bool isActive;
  int minimumScore;
  int maximumScore;

  ScoreType({
    required this.scoreTypeId,
    required this.scoreTypeDesc,
    required this.scoreWeight,
    required this.isActive,
    required this.minimumScore,
    required this.maximumScore,
  });

  factory ScoreType.fromJson(Map<String, dynamic> json) => ScoreType(
        scoreTypeId: json["score_type_id"],
        scoreTypeDesc: json["score_type_desc"],
        scoreWeight: json["score_weight"],
        isActive: json["is_active"],
        minimumScore: json["minimum_score"],
        maximumScore: json["maximum_score"],
      );
}
