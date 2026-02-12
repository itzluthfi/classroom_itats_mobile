import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:classroom_itats_mobile/models/forum.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:classroom_itats_mobile/user/repositories/forum_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

part 'forum_event.dart';
part 'forum_state.dart';

class ForumBloc extends Bloc<ForumEvent, ForumState> {
  final ForumRepository forumRepository;

  ForumBloc({required this.forumRepository}) : super(ForumInitial()) {
    on<StoreFileForum>((event, emit) async {
      emit(StoreFileForumLoading());
      try {
        var forums =
            await forumRepository.storeForumFile(event.path, event.filename);

        if (forums.statusCode != 201) {
          emit(StoreFileForumFailed());
        } else {
          var decodedData = forums.data as Map<String, dynamic>;

          emit(StoreFileForumSuccess(filepath: decodedData["path"] as String));
        }
      } catch (e) {
        emit(StoreFileForumFailed());
      }
    });
    on<ForumEvent>(
      (ForumEvent event, Emitter<ForumState> emit) async {
        if (event is CreateForumComment) {
          emit(CreateForumLoading());
          try {
            var forums = await forumRepository.createForumComment(
              event.announcementId,
              event.commentContent,
              event.createdAt,
              event.updatedAt,
            );

            if (forums != 201) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body:
                      "Mohon maaf, sistem gagal menyimpan komentar pengumuman anda");

              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success",
                  body: "Sukses menyimpan komentar pengumuman anda");

              emit(CreateForumSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body:
                    "Mohon maaf, sistem gagal menyimpan komentar pengumuman anda");

            emit(CreateForumFailed());
          }
        } else if (event is UpdateForumComment) {
          emit(CreateForumLoading());
          try {
            var forums = await forumRepository.updateForumComment(
              event.commentId,
              event.announcementId,
              event.commentContent,
              event.updatedAt,
            );

            if (forums != 200) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body:
                      "Mohon maaf, sistem gagal menyimpan komentar pengumuman anda");

              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success",
                  body: "Sukses menyimpan komentar pengumuman anda");

              emit(CreateForumSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body:
                    "Mohon maaf, sistem gagal menyimpan komentar pengumuman anda");

            emit(CreateForumFailed());
          }
        } else if (event is DeleteForumComment) {
          try {
            var forums =
                await forumRepository.deleteForumComment(event.commentId);

            if (forums != 200) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body:
                      "Mohon maaf, sistem gagal menghapus komentar pengumuman anda");
              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success",
                  body: "Sukses menghapus komentar pengumuman anda");
              emit(CreateForumSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body:
                    "Mohon maaf, sistem gagal menghapus komentar pengumuman anda");

            emit(CreateForumFailed());
          }
        } else if (event is CreateForum) {
          emit(CreateForumLoading());
          try {
            for (var delta in event.deltaOps) {
              if (delta["insert"] is Map<String, dynamic>) {
                if (delta["insert"]["image"] != null) {
                  var temp = (delta["insert"]["image"] as String).split("/");
                  var forums = await forumRepository.storeForumFile(
                      delta["insert"]["image"], temp.last);

                  if (forums.statusCode != 201) {
                    await NotificationService().showNotification(
                        title: "Failed",
                        body:
                            "Mohon maaf, sistem gagal menyimpan pengumuman anda");
                    emit(CreateForumFailed());
                  } else {
                    var decodedData = forums.data as Map<String, dynamic>;
                    delta["insert"]["image"] = decodedData["path"];
                  }
                }
                if (delta["insert"]["video"] != null) {
                  var temp = (delta["insert"]["video"] as String).split("/");
                  var forums = await forumRepository.storeForumFile(
                      delta["insert"]["video"], temp.last);

                  if (forums.statusCode != 201) {
                    await NotificationService().showNotification(
                        title: "Failed",
                        body:
                            "Mohon maaf, sistem gagal menyimpan pengumuman anda");
                    emit(CreateForumFailed());
                  } else {
                    var decodedData = forums.data as Map<String, dynamic>;
                    delta["insert"]["video"] = decodedData["path"];
                  }
                }
              }
            }

            final converter = QuillDeltaToHtmlConverter(
                event.deltaOps, ConverterOptions.forEmail());
            final html = converter.convert();

            var forums = await forumRepository.createForum(
                event.activityMasterId, html, event.createdAt, event.updatedAt);

            if (forums != 201) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menyimpan pengumuman anda");
              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses membuat pengumuman baru");
              emit(CreateForumSuccess());
            }
          } catch (e) {
            emit(CreateForumFailed());
          }
        } else if (event is UpdateForum) {
          emit(CreateForumLoading());
          try {
            for (var delta in event.deltaOps) {
              if (delta["insert"] is Map<String, dynamic>) {
                if (delta["insert"]["image"] != null) {
                  var temp = (delta["insert"]["image"] as String).split("/");
                  var forums = await forumRepository.storeForumFile(
                      delta["insert"]["image"], temp.last);

                  if (forums.statusCode != 201) {
                    await NotificationService().showNotification(
                        title: "Failed",
                        body:
                            "Mohon maaf, sistem gagal menyimpan pengumuman anda");
                    emit(CreateForumFailed());
                  } else {
                    var decodedData = forums.data as Map<String, dynamic>;
                    delta["insert"]["image"] = decodedData["path"];
                  }
                }
                if (delta["insert"]["video"] != null) {
                  var temp = (delta["insert"]["video"] as String).split("/");
                  var forums = await forumRepository.storeForumFile(
                      delta["insert"]["video"], temp.last);

                  if (forums.statusCode != 201) {
                    await NotificationService().showNotification(
                        title: "Failed",
                        body:
                            "Mohon maaf, sistem gagal menyimpan pengumuman anda");
                    emit(CreateForumFailed());
                  } else {
                    var decodedData = forums.data as Map<String, dynamic>;
                    delta["insert"]["video"] = decodedData["path"];
                  }
                }
              }
            }

            final converter = QuillDeltaToHtmlConverter(
                event.deltaOps, ConverterOptions.forEmail());
            final html = converter.convert();

            var forums = await forumRepository.updateForum(event.announcementId,
                event.activityMasterId, html, event.createdAt, event.updatedAt);

            if (forums != 200) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menyimpan pengumuman anda");
              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses mengubah pengumuman anda");
              emit(CreateForumSuccess());
            }
          } catch (e) {
            emit(CreateForumFailed());
          }
        } else if (event is DeleteForum) {
          try {
            var forums =
                await forumRepository.deleteForum(event.announcementId);

            if (forums != 200) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menghapus pengumuman anda");
              emit(CreateForumFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses menghapus pengumuman anda");
              emit(CreateForumSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body: "Mohon maaf, sistem gagal menghapus pengumuman anda");

            emit(CreateForumFailed());
          }
        } else if (event is GetForum) {
          emit(ForumLoading());
          try {
            var forums = await forumRepository.forum(event.masterActivityId);

            emit(ForumLoaded(announcement: forums));
          } catch (e) {
            emit(ForumLoadFailed());
          }
        }
      },
      transformer: sequential(),
    );
  }
}
