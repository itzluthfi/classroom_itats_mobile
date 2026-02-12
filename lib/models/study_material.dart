class StudyMaterial {
  String materialId;
  String lecturerId;
  String materialTitle;
  String materialLink;
  String createdAt;
  String updatedAt;
  String deletedAt;
  int hiddenStatus;
  String lectureMaterialID;
  String lectureID;

  StudyMaterial({
    required this.materialId,
    required this.lecturerId,
    required this.materialTitle,
    required this.materialLink,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.hiddenStatus,
    required this.lectureMaterialID,
    required this.lectureID,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) => StudyMaterial(
        materialId: json["material_id"],
        lecturerId: json["lecturer_id"],
        materialTitle: json["material_title"],
        materialLink: json["material_link"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        hiddenStatus: json["hidden_status"],
        lectureMaterialID: json["lecture_material_id"],
        lectureID: json["lecture_id"],
      );
}
