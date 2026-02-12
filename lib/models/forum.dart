import 'package:classroom_itats_mobile/models/study_material.dart';

class Announcement {
  int announcementId;
  String postContent;
  String createdAt;
  String authorId;
  String author;
  String photo;
  List<StudyMaterial> materials;
  List<Comment> comments;

  Announcement({
    required this.announcementId,
    required this.postContent,
    required this.createdAt,
    required this.author,
    required this.authorId,
    required this.photo,
    required this.materials,
    required this.comments,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        announcementId: json["announcement_id"],
        postContent: json["post_content"],
        createdAt: json["created_at"],
        author: json["author"],
        authorId: json["author_id"],
        photo: json["photo"],
        materials: (json["materials"] as List)
            .map((data) => StudyMaterial(
                  materialId: data["materi_id"],
                  lecturerId: data["dosid"],
                  materialTitle: data["judul_materi"],
                  materialLink: data["link_materi"],
                  createdAt: data["created_at"],
                  updatedAt: data["updated_at"],
                  deletedAt: data["deleted_at"],
                  hiddenStatus: data["hidden_status"],
                  lectureMaterialID: data["kul_materi_id"],
                  lectureID: data["kul_id"],
                ))
            .toList(),
        comments: (json["comments"] as List)
            .map((data) => Comment.fromJson(data))
            .toList(),
      );
}

class Comment {
  int commentId;
  int announcementId;
  String commentContent;
  String createdAt;
  String author;
  String authorId;
  String photo;

  Comment({
    required this.commentId,
    required this.announcementId,
    required this.commentContent,
    required this.createdAt,
    required this.author,
    required this.authorId,
    required this.photo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        commentId: json["id_post_comment"],
        announcementId: json["post_klstw_id"],
        commentContent: json["content_comment"],
        createdAt: json["created_at"],
        author: json["nama"],
        authorId: json["author_id"],
        photo: json["foto"],
      );
}
