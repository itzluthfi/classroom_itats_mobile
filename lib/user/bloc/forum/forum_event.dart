part of 'forum_bloc.dart';

sealed class ForumEvent extends Equatable {
  const ForumEvent();

  @override
  List<Object> get props => [];
}

class GetForum extends ForumEvent {
  final String masterActivityId;

  const GetForum({required this.masterActivityId});

  @override
  List<Object> get props => [masterActivityId];

  @override
  String toString() => "GetForum {masterActivityId: $masterActivityId}";
}

class StoreFileForum extends ForumEvent {
  final String path;
  final String filename;

  const StoreFileForum({required this.path, required this.filename});

  @override
  List<Object> get props => [path, filename];

  @override
  String toString() => "StoreFileForum {path: $path, filename: $filename}";
}

class CreateForum extends ForumEvent {
  final List<Map<String, dynamic>> deltaOps;
  final String activityMasterId;
  final String createdAt;
  final String updatedAt;

  const CreateForum({
    required this.activityMasterId,
    required this.createdAt,
    required this.updatedAt,
    required this.deltaOps,
  });

  @override
  List<Object> get props => [deltaOps, activityMasterId, createdAt, updatedAt];

  @override
  String toString() => "CreateForum {deltaOps: $deltaOps}";
}

class UpdateForum extends ForumEvent {
  final List<Map<String, dynamic>> deltaOps;
  final int announcementId;
  final String activityMasterId;
  final String createdAt;
  final String updatedAt;

  const UpdateForum({
    required this.announcementId,
    required this.activityMasterId,
    required this.createdAt,
    required this.updatedAt,
    required this.deltaOps,
  });

  @override
  List<Object> get props =>
      [deltaOps, announcementId, activityMasterId, createdAt, updatedAt];

  @override
  String toString() => "UpdateForum {deltaOps: $deltaOps}";
}

class DeleteForum extends ForumEvent {
  final int announcementId;

  const DeleteForum({
    required this.announcementId,
  });

  @override
  List<Object> get props => [announcementId];

  @override
  String toString() => "DeleteForum {announcementId: $announcementId}";
}

class CreateForumComment extends ForumEvent {
  final int announcementId;
  final String commentContent;
  final String createdAt;
  final String updatedAt;

  const CreateForumComment({
    required this.announcementId,
    required this.commentContent,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object> get props =>
      [announcementId, commentContent, createdAt, updatedAt];

  @override
  String toString() =>
      "CreateForum {announcementId: $announcementId, commentContent: $commentContent, createdAt: $createdAt, updatedAt: $updatedAt}";
}

class UpdateForumComment extends ForumEvent {
  final int commentId;
  final int announcementId;
  final String commentContent;
  final String updatedAt;

  const UpdateForumComment({
    required this.commentId,
    required this.announcementId,
    required this.commentContent,
    required this.updatedAt,
  });

  @override
  List<Object> get props =>
      [commentId, announcementId, commentContent, updatedAt];

  @override
  String toString() =>
      "CreateForum {commentId: $commentId, announcementId: $announcementId, commentContent: $commentContent, updatedAt: $updatedAt}";
}

class DeleteForumComment extends ForumEvent {
  final int commentId;

  const DeleteForumComment({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];

  @override
  String toString() => "DeleteForumComment {commentId: $commentId}";
}
