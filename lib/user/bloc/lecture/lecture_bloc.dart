import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/lecture.dart';
import 'package:classroom_itats_mobile/models/lecture_presence.dart';
import 'package:classroom_itats_mobile/models/presence.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:classroom_itats_mobile/user/repositories/lecture_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/presence_repository.dart';
import 'package:equatable/equatable.dart';

part 'lecture_event.dart';
part 'lecture_state.dart';

class LectureBloc extends Bloc<LectureEvent, LectureState> {
  final LectureRepository lectureRepository;
  final PresenceRepository presenceRepository;

  LectureBloc(
      {required this.lectureRepository, required this.presenceRepository})
      : super(LectureInitial()) {
    on<GetLecture>((event, emit) async {
      emit(LectureLoading());
      try {
        var lecture = await lectureRepository.getLecture(
            event.academicPeriod, event.subjectId, event.subjectClass);

        emit(LectureLoaded(
          lectures: List.empty(),
          lecturerLectures: lecture,
          responsiLectures: List.empty(),
          lectureReports: List.empty(),
          lectureReport: Lecture(),
        ));
      } catch (e) {
        emit(LectureLoadFailed());
      }
    });
    on<GetStudentLecture>((event, emit) async {
      emit(LectureLoading());
      try {
        var lecture = await lectureRepository.getStudentLecture(
            event.academicPeriod, event.subjectId, event.subjectClass);

        Map<String, dynamic> decodedData = lecture.data["data"];

        var materialLectures = List<Lecture>.empty();
        var responsiLectures = List<List<Lecture>>.empty();

        if ((decodedData["material_lectures"] as List).isNotEmpty) {
          materialLectures = await lectureRepository
              .setMaterialLecture(decodedData["material_lectures"] as List);
        }

        if ((decodedData["responsi_lectures"] as List).isNotEmpty) {
          responsiLectures = await lectureRepository
              .setResponsiLecture(decodedData["responsi_lectures"] as List);
        }

        var presences = await presenceRepository.getPresence(
            event.academicPeriod, event.subjectId, event.subjectClass);

        decodedData = presences.data["data"];

        var materialPresences = List<Presence>.empty();
        var responsiPresences = List<List<Presence>>.empty();

        if ((decodedData["material_presences"] as List).isNotEmpty) {
          materialPresences = await presenceRepository
              .setMaterialPresence(decodedData["material_presences"] as List);
        }

        if ((decodedData["responsi_presences"] as List).isNotEmpty) {
          responsiPresences = await presenceRepository
              .setResponsiPresence(decodedData["responsi_presences"] as List);
        }

        var materialLecturePresences =
            List<LecturePresence>.filled(16, LecturePresence());

        var responsiLecturePresences = List<List<LecturePresence>>.filled(
            responsiPresences.length, List.filled(16, LecturePresence()));

        for (var i = 0; i < materialLectures.length; i++) {
          materialLecturePresences[materialLectures[i].weekID! - 1] =
              LecturePresence(
            lecture: materialLectures[i],
          );
        }

        if (materialPresences.isNotEmpty) {
          for (var i = 0; i < materialPresences.length; i++) {
            materialLecturePresences[materialPresences[i].weekID - 1] =
                LecturePresence(
              lecture: materialLecturePresences[materialPresences[i].weekID - 1]
                  .lecture,
              presence: materialPresences[i],
            );
          }
        }

        if (responsiLectures.isNotEmpty) {
          for (var i = 0; i < responsiLectures.length; i++) {
            if (responsiLectures[i].isNotEmpty) {
              for (var j = 0; j < responsiLectures[i].length; j++) {
                responsiLecturePresences[i]
                    [responsiLectures[i][j].weekID! - 1] = LecturePresence(
                  lecture: responsiLectures[i][j],
                );
              }
            }
          }
        }

        if (responsiPresences.isNotEmpty) {
          for (var i = 0; i < responsiPresences.length; i++) {
            if (responsiPresences[i].isNotEmpty) {
              for (var j = 0; j < responsiPresences[i].length; j++) {
                responsiLecturePresences[i]
                    [responsiPresences[i][j].weekID - 1] = LecturePresence(
                  lecture: responsiLecturePresences[i]
                          [responsiPresences[i][j].weekID - 1]
                      .lecture,
                  presence: responsiPresences[i][j],
                );
              }
            }
          }
        } else {
          responsiLecturePresences = List.empty();
        }

        emit(LectureLoaded(
          lectures: materialLecturePresences,
          lecturerLectures: List.empty(),
          responsiLectures: responsiLecturePresences,
          lectureReports: List.empty(),
          lectureReport: Lecture(),
        ));
      } catch (e) {
        emit(LectureLoadFailed());
      }
    });
    on<DownloadMaterial>((event, emit) async {
      emit(MaterialFileDownloadLoading());
      try {
        var code = await lectureRepository.downloadMaterialFile(event.fileLink);

        if (code == 200) {
          await NotificationService().showNotification(
              title: "Success", body: "Sukses mendownload tugas baru");
          emit(MaterialFileDownloadSuccess());
        } else {
          await NotificationService().showNotification(
              title: "Failed",
              body: "Mohon maaf, sistem gagal mendownload tugas baru");
          emit(MaterialFileDownloadFailed());
        }
      } catch (e) {
        await NotificationService().showNotification(
            title: "Failed",
            body: "Mohon maaf, sistem gagal mendownload tugas baru");
        emit(MaterialFileDownloadFailed());
      }
    });
    on<GetLectureReport>((event, emit) async {
      emit(LectureLoading());
      try {
        var lecture = await lectureRepository.getLectureReport(event.subjectId,
            event.subjectClass, event.hourId, event.collegeType);

        emit(LectureLoaded(
          lectures: List.empty(),
          lecturerLectures: List.empty(),
          responsiLectures: List.empty(),
          lectureReports: lecture,
          lectureReport: Lecture(),
        ));
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        emit(LectureLoadFailed());
      }
    });
    on<GetDetailLectureReport>((event, emit) async {
      emit(LectureLoading());
      try {
        var lecture =
            await lectureRepository.getDetailLectureReport(event.lectureId);

        emit(LectureLoaded(
          lectures: List.empty(),
          lecturerLectures: List.empty(),
          responsiLectures: List.empty(),
          lectureReports: List.empty(),
          lectureReport: lecture,
        ));
      } catch (e) {
        emit(LectureLoadFailed());
      }
    });
    on<CreateLectureReport>((event, emit) async {
      emit(LectureCreateLoading());
      try {
        var status = await lectureRepository.storeLectureReport(
          event.academicPeriodId,
          event.subjectId,
          event.majorId,
          event.lecturerId,
          event.subjectClass,
          event.lectureSchedule,
          event.lectureType,
          event.subjectCredit,
          event.hourId,
          event.material,
          event.entryTime,
          event.approvalStatus,
          event.weekId,
          event.timeRealization,
          event.materialRealization,
          event.presenceLimit,
          event.collegeType,
        );

        if (status == 200) {
          await NotificationService().showNotification(
              title: "Success", body: "Sukses membuat pelaporan");
          emit(LectureCreateSuccess());
        } else {
          await NotificationService().showNotification(
              title: "Failed",
              body: "Mohon maaf, sistem gagal membuat pelaporan");
          emit(LectureCreateFailed());
        }
      } catch (e) {
        await NotificationService().showNotification(
            title: "Failed",
            body: "Mohon maaf, sistem gagal membuat pelaporan");
        emit(LectureCreateFailed());
      }
    });
    on<EditLectureReport>((event, emit) async {
      emit(LectureEditLoading());
      try {
        var status = await lectureRepository.editLectureReport(
          event.lectureId,
          event.academicPeriodId,
          event.subjectId,
          event.majorId,
          event.lecturerId,
          event.subjectClass,
          event.lectureSchedule,
          event.lectureType,
          event.subjectCredit,
          event.hourId,
          event.material,
          event.entryTime,
          event.approvalStatus,
          event.weekId,
          event.timeRealization,
          event.materialRealization,
          event.presenceLimit,
          event.collegeType,
        );

        if (status == 200) {
          await NotificationService().showNotification(
              title: "Success", body: "Sukses mengubah pelaporan");
          emit(LectureEditSuccess());
        } else {
          await NotificationService().showNotification(
              title: "Failed",
              body: "Mohon maaf, sistem gagal mengubah pelaporan");
          emit(LectureEditFailed());
        }
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        await NotificationService().showNotification(
            title: "Failed",
            body: "Mohon maaf, sistem gagal mengubah pelaporan");
        emit(LectureEditFailed());
      }
    });
    on<DeleteLectureReport>((event, emit) async {
      emit(LectureEditLoading());
      try {
        var status = await lectureRepository.deleteLectureReport(
          event.lectureId,
        );

        if (status == 200) {
          await NotificationService().showNotification(
              title: "Success", body: "Sukses menghapus pelaporan");
          emit(LectureEditSuccess());
        } else {
          await NotificationService().showNotification(
              title: "Failed",
              body: "Mohon maaf, sistem gagal menghapus pelaporan");
          emit(LectureDeleteFailed());
        }
      } catch (e) {
        emit(LectureDeleteFailed());
      }
    });
    on<ClearStateLecture>((event, emit) {
      emit(LectureInitial());
    });
  }
}
