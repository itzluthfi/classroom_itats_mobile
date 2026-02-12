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
            .getStudyAssignment(event.masterActivityId);

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
            .getStudentAssignmentScore(event.masterActivityId);

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
          try {
            var code = await assignmentRepository.downloadAssignmentFile(
                event.fileLink, event.fileName);

            if (code == 200) {
              await NotificationService().showNotification(
                  title: "Success",
                  body: "Sukses mendownload file submission anda");
              emit(AssignmentFileDownloadSuccess());
            } else {
              await NotificationService().showNotification(
                  title: "Failed",
                  body:
                      "Mohon maaf, sistem gagal mendownload file submission anda");
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body:
                    "Mohon maaf, sistem gagal mendownload file submission anda");
            emit(AssignmentFileDownloadFailed());
          }
        } else if (event is DownloadAssignment) {
          emit(AssignmentFileDownloadLoading());
          try {
            var code = await assignmentRepository.downloadAssignmentFile(
                event.fileLink, event.fileName);

            if (code == 200) {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses mendownload file tugas");
              emit(AssignmentFileDownloadSuccess());
            } else {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal mendownload file tugas");
              emit(AssignmentFileDownloadFailed());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body: "Mohon maaf, sistem gagal mendownload file tugas");
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

            if (status != 201) {
              await NotificationService().showNotification(
                  title: "Failed",
                  body: "Mohon maaf, sistem gagal menyimpan submission anda");
              emit(CreateAssignmentFailed());
            } else {
              await NotificationService().showNotification(
                  title: "Success", body: "Sukses menyimpan submission anda");
              emit(CreateAssignmentSuccess());
            }
          } catch (e) {
            await NotificationService().showNotification(
                title: "Failed",
                body: "Mohon maaf, sistem gagal menyimpan submission anda");
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
