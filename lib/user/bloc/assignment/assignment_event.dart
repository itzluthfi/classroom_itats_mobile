part of 'assignment_bloc.dart';

sealed class AssignmentEvent extends Equatable {
  const AssignmentEvent();

  @override
  List<Object> get props => [];
}

class GetStudentAssignment extends AssignmentEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudentAssignment({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudentAssignment {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}

class GetActiveAssignments extends AssignmentEvent {
  final String period;

  const GetActiveAssignments({required this.period});

  @override
  List<Object> get props => [period];

  @override
  String toString() => "GetActiveAssignments {period: $period}";
}

class GetStudentAssignmentWeek extends AssignmentEvent {
  final String masterActivityId;
  final int weekId;

  const GetStudentAssignmentWeek({
    required this.masterActivityId,
    required this.weekId,
  });

  @override
  List<Object> get props => [masterActivityId];

  @override
  String toString() =>
      "GetStudentAssignmentWeek {masterActivityId: $masterActivityId, weekId: $weekId}";
}

class GetStudentSubmitedAssignment extends AssignmentEvent {
  final int assignmentId;

  const GetStudentSubmitedAssignment({
    required this.assignmentId,
  });

  @override
  List<Object> get props => [assignmentId];

  @override
  String toString() =>
      "GetStudentSubmitedAssignment {assignmentId: $assignmentId}";
}

class GetStudentAssignmentScore extends AssignmentEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudentAssignmentScore({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudentAssignmentScore {academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}

class GetLecturerAssignment extends AssignmentEvent {
  final String academicPeriodId;

  const GetLecturerAssignment({
    required this.academicPeriodId,
  });

  @override
  List<Object> get props => [academicPeriodId];

  @override
  String toString() =>
      "GetLecturerAssignment {masterActivityId: $academicPeriodId}";
}

class GetCreateAssignment extends AssignmentEvent {
  final String academicPeriodId;
  final String major;

  const GetCreateAssignment({
    required this.academicPeriodId,
    required this.major,
  });

  @override
  List<Object> get props => [academicPeriodId, major];

  @override
  String toString() =>
      "GetCreateAssignment {academicPeriodId: $academicPeriodId, major: $major}";
}

class DownloadAssignment extends AssignmentEvent {
  final String fileLink;
  final String fileName;

  const DownloadAssignment({
    required this.fileLink,
    required this.fileName,
  });

  @override
  List<Object> get props => [fileLink, fileName];

  @override
  String toString() =>
      "DownloadAssignment {fileLink: $fileLink, fileName: $fileName}";
}

class DownloadStudentAssignmentSubmission extends AssignmentEvent {
  final String fileLink;
  final String fileName;

  const DownloadStudentAssignmentSubmission({
    required this.fileLink,
    required this.fileName,
  });

  @override
  List<Object> get props => [fileLink, fileName];

  @override
  String toString() =>
      "DownloadStudentAssignmentSubmission {fileLink: $fileLink, fileName: $fileName}";
}

class CreateAssignment extends AssignmentEvent {
  final String activityMasterId;
  final String weekId;
  final String scoreType;
  final String assignmentTitle;
  final String assignmentDescription;
  final String dueDate;
  final String isShow;
  final String filepath;
  final String filename;

  const CreateAssignment({
    required this.activityMasterId,
    required this.weekId,
    required this.scoreType,
    required this.assignmentTitle,
    required this.assignmentDescription,
    required this.dueDate,
    required this.isShow,
    required this.filepath,
    required this.filename,
  });

  @override
  List<Object> get props => [
        activityMasterId,
        weekId,
        scoreType,
        assignmentTitle,
        assignmentDescription,
        dueDate,
        isShow,
        filepath,
        filename
      ];

  @override
  String toString() =>
      "CreateAssignment {activityMasterId: $activityMasterId, weekId: $weekId, scoreType: $scoreType, assignmentTitle: $assignmentTitle, assignmentDescription: $assignmentDescription, dueDate: $dueDate, isShow: $isShow, filepath: $filepath, filename: $filename}";
}

class SubmitAssignment extends AssignmentEvent {
  final int assignmentId;
  final String note;
  final String fileLink;
  final String fileName;

  const SubmitAssignment({
    required this.assignmentId,
    required this.note,
    required this.fileLink,
    required this.fileName,
  });

  @override
  List<Object> get props => [assignmentId, note, fileLink, fileName];

  @override
  String toString() =>
      "SubmitAssignment {assignmentId: $assignmentId, note: $note,fileLink: $fileLink, fileName: $fileName}";
}
