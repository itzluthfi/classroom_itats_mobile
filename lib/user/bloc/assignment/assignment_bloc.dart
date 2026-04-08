import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:classroom_itats_mobile/models/assignment.dart';
import 'package:classroom_itats_mobile/models/score_type.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/models/week.dart';
import 'package:classroom_itats_mobile/user/repositories/assignment_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:classroom_itats_mobile/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'assignment_event.dart';
part 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final AssignmentRepository assignmentRepository;
  final SubjectRepository subjectRepository;

  AssignmentBloc(
      {required this.assignmentRepository, required this.subjectRepository})
      : super(AssignmentInitial()) {
    on<GetStudentAssignment>((event, emit) async {
      emit(AssignmentLoading());
      try {
        var assignments = await assignmentRepository
            .getStudyAssignment(
              event.academicPeriod,
              event.subjectId,
              event.subjectClass,
            );

        emit(AssignmentLoaded(
          assignments: assignments,
          assignmentsJoin: List.empty(),
          studentAssigmentScores: List.empty(),
          subjects: List.empty(),
          scoreType: List.empty(),
          weekAssignments: List.empty(),
          studentAssignmentSubmission: null,
        ));
      } catch (e) {
        emit(AssignmentLoadFailed());
      }
    });

    on<GetActiveAssignments>((event, emit) async {
      emit(AssignmentLoading());
      try {
        var assignments =
            await assignmentRepository.getActiveAssignments(event.period);

        emit(AssignmentLoaded(
          assignments: assignments,
          assignmentsJoin: List.empty(),
          studentAssigmentScores: List.empty(),
          subjects: List.empty(),
          scoreType: List.empty(),
          weekAssignments: List.empty(),
          studentAssignmentSubmission: null,
        ));
      } catch (e) {
        emit(AssignmentLoadFailed());
      }
    });

    on<GetStudentAssignmentWeek>((event, emit) async {
      emit(AssignmentLoading());
      try {
        var assignments = await assignmentRepository.getStudyAssignmentWeek(
            event.masterActivityId, event.weekId);

        emit(AssignmentLoaded(
          assignments: List.empty(),
          assignmentsJoin: assignments,
          studentAssigmentScores: List.empty(),
          subjects: List.empty(),
          scoreType: List.empty(),
          weekAssignments: List.empty(),
          studentAssignmentSubmission: null,
        ));
      } catch (e) {
        emit(AssignmentLoadFailed());
      }
    });
    on<GetLecturerAssignment>((event, emit) async {
      emit(AssignmentLoading());
      try {
        var assignments = await assignmentRepository
            .getLecturerCreatedAssignment(event.academicPeriodId);

        emit(AssignmentLoaded(
          assignments: assignments,
          assignmentsJoin: List.empty(),
          studentAssigmentScores: List.empty(),
          subjects: List.empty(),
          scoreType: List.empty(),
          weekAssignments: List.empty(),
          studentAssignmentSubmission: null,
        ));
      } catch (e) {
        emit(AssignmentLoadFailed());
      }
    });

    on<GetStudentAssignmentScore>((event, emit) async {
      emit(AssignmentLoading());
      try {
        var assignmentScores = await assignmentRepository
            .getStudentAssignmentScore(
              event.academicPeriod,
              event.subjectId,
              event.subjectClass,
            );

        emit(AssignmentLoaded(
          assignments: List.empty(),
          assignmentsJoin: List.empty(),
          studentAssigmentScores: assignmentScores,
          subjects: List.empty(),
          scoreType: List.empty(),
          weekAssignments: List.empty(),
          studentAssignmentSubmission: null,
        ));
      } catch (e) {
        emit(AssignmentLoadFailed());
      }
    });
    on<AssignmentEvent>(
      (AssignmentEvent event, Emitter<AssignmentState> emit) async {
        if (event is DownloadStudentAssignmentSubmission) {
          emit(AssignmentFileDownloadLoading());
          final savedPath = await assignmentRepository.downloadAssignmentFile(
              event.fileLink, event.fileName);

          // Notif dalam try-catch terpisah — JANGAN biarkan failure notif
          // membuat state menjadi Failed padahal file sudah tersimpan
          try {
            if (savedPath != null) {
              await NotificationService().showNotification(
                  title: "Unduhan Berhasil",
                  body: "File tersimpan di folder Download perangkat Anda.");
            } else {
              await NotificationService().showNotification(
                  title: "Unduhan Gagal",
                  body: "Gagal mengunduh file. Cek koneksi internet.");
            }
          } catch (_) {/* abaikan error notifikasi */}

          // Emit state berdasarkan hasil download, BUKAN notifikasi
          if (savedPath != null) {
            emit(AssignmentFileDownloadSuccess());
          } else {
            emit(AssignmentFileDownloadFailed());
          }

        } else if (event is DownloadAssignment) {
          emit(AssignmentFileDownloadLoading());
          final savedPath = await assignmentRepository.downloadAssignmentFile(
              event.fileLink, event.fileName);

          try {
            if (savedPath != null) {
              await NotificationService().showNotification(
                  title: "Unduhan Berhasil",
                  body: "File tugas tersimpan di folder Download perangkat Anda.");
            } else {
              await NotificationService().showNotification(
                  title: "Unduhan Gagal",
                  body: "Gagal mengunduh file tugas. Cek koneksi internet.");
            }
          } catch (_) {/* abaikan error notifikasi */}

          if (savedPath != null) {
            emit(AssignmentFileDownloadSuccess());
          } else {
            emit(AssignmentFileDownloadFailed());
          }

        } else if (event is CreateAssignment) {
          emit(CreateAssignmentLoading());
          try {
            var status = await assignmentRepository.createAssignment(
              event.activityMasterId,
              event.weekId,
              event.scoreType,
              event.assignmentTitle,
              event.assignmentDescription,
              event.dueDate,
              event.isShow,
              event.filepath,
              event.filename,
            );

            if (status != 201) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal membuat tugas baru");
              emit(CreateAssignmentFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses membuat tugas baru");
              emit(CreateAssignmentSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body: "Mohon maaf, sistem gagal membuat tugas baru");
            emit(CreateAssignmentFailed());
          }
        } else if (event is SubmitAssignment) {
          emit(CreateAssignmentLoading());
          try {
            var status = await assignmentRepository.submitAssignment(
              event.assignmentId,
              event.note,
              event.fileLink,
              event.fileName,
            );

            if (status != 201 && status != 200) {
              try {
                await NotificationService().showNotification(
                    title: "Failed",
                    body: "Mohon maaf, sistem gagal menyimpan submission anda");
              } catch (_) {}
              emit(CreateAssignmentFailed());
            } else {
              try {
                await NotificationService().showNotification(
                    title: "Success", body: "Sukses menyimpan submission anda");
              } catch (_) {}
              emit(CreateAssignmentSuccess());
            }
          } catch (e) {
            try {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menyimpan submission anda");
            } catch (_) {}
            emit(CreateAssignmentFailed());
          }
        } else if (event is GetStudentSubmitedAssignment) {
          emit(AssignmentLoading());
          try {
            var assignmentSubmited = await assignmentRepository
                .getStudentSubmitedAssignment(event.assignmentId);

            emit(AssignmentLoaded(
              assignments: List.empty(),
              assignmentsJoin: List.empty(),
              studentAssigmentScores: List.empty(),
              subjects: List.empty(),
              scoreType: List.empty(),
              weekAssignments: List.empty(),
              studentAssignmentSubmission: assignmentSubmited,
            ));
          } catch (e) {
            emit(AssignmentLoadFailed());
          }
        } else if (event is GetCreateAssignment) {
          emit(AssignmentLoading());
          try {
            var subjects = await subjectRepository.getSubjectsFiltered(
                event.academicPeriodId, event.major);
            var scoreType = await assignmentRepository.getScoreType();
            var weekAssignment = await assignmentRepository.getWeekAssignment();

            emit(AssignmentLoaded(
              assignments: List.empty(),
              assignmentsJoin: List.empty(),
              studentAssigmentScores: List.empty(),
              subjects: subjects,
              scoreType: scoreType,
              weekAssignments: weekAssignment,
              studentAssignmentSubmission: null,
            ));
          } catch (e) {
            emit(AssignmentLoadFailed());
          }
        }
      },
      transformer: sequential(),
    );
  }
}
