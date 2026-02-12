part of 'forum_bloc.dart';

sealed class ForumState extends Equatable {
  const ForumState();

  @override
  List<Object> get props => [];
}

final class ForumInitial extends ForumState {}

final class ForumLoading extends ForumState {}

final class ForumLoaded extends ForumState {
  final List<Announcement> announcement;

  const ForumLoaded({required this.announcement});

  @override
  List<Object> get props => [announcement];

  @override
  String toString() => "${announcement.length} forum loaded";
}

final class ForumLoadFailed extends ForumState {}

final class CreateForumLoading extends ForumState {}

final class CreateForumSuccess extends ForumState {}

final class CreateForumFailed extends ForumState {}

final class StoreFileForumLoading extends ForumState {}

final class StoreFileForumSuccess extends ForumState {
  final String filepath;

  const StoreFileForumSuccess({required this.filepath});

  @override
  List<Object> get props => [filepath];

  @override
  String toString() => "forum file stored in $filepath";
}

final class StoreFileForumFailed extends ForumState {}
