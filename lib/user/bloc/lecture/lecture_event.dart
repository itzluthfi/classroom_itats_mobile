part of 'lecture_bloc.dart';

sealed class LectureEvent extends Equatable {
  const LectureEvent();

  @override
  List<Object> get props => [];
}

class GetLecture extends LectureEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetLecture({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetLecture{academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}

class GetStudentLecture extends LectureEvent {
  final String academicPeriod;
  final String subjectId;
  final String subjectClass;

  const GetStudentLecture({
    required this.academicPeriod,
    required this.subjectId,
    required this.subjectClass,
  });

  @override
  List<Object> get props => [academicPeriod, subjectId, subjectClass];

  @override
  String toString() =>
      "GetStudentLecture{academicPeriod: $academicPeriod, subjectId: $subjectId, subjectClass: $subjectClass}";
}

class DownloadMaterial extends LectureEvent {
  final String fileLink;

  const DownloadMaterial({
    required this.fileLink,
  });

  @override
  List<Object> get props => [fileLink];

  @override
  String toString() => "DownloadMaterial {fileLink: $fileLink}";
}

class GetLectureReport extends LectureEvent {
  final String subjectId;
  final String subjectClass;
  final String hourId;
  final String collegeType;

  const GetLectureReport({
    required this.subjectId,
    required this.subjectClass,
    required this.hourId,
    required this.collegeType,
  });

  @override
  List<Object> get props => [subjectId, subjectClass, hourId, collegeType];

  @override
  String toString() =>
      "GetLecture{subjectId: $subjectId, subjectClass: $subjectClass, hourId: $hourId, collegeType: $collegeType}";
}

class CreateLectureReport extends LectureEvent {
  final String academicPeriodId;
  final String subjectId;
  final String majorId;
  final String lecturerId;
  final String subjectClass;
  final String lectureSchedule;
  final String lectureType;
  final int subjectCredit;
  final String hourId;
  final List<Map<String, String>> material;
  final String entryTime;
  final int approvalStatus;
  final int weekId;
  final int timeRealization;
  final String materialRealization;
  final String presenceLimit;
  final int collegeType;
  final String linkMeet;

  const CreateLectureReport({
    required this.academicPeriodId,
    required this.subjectId,
    required this.majorId,
    required this.lecturerId,
    required this.subjectClass,
    required this.lectureSchedule,
    required this.lectureType,
    required this.subjectCredit,
    required this.hourId,
    required this.material,
    required this.entryTime,
    required this.approvalStatus,
    required this.weekId,
    required this.timeRealization,
    required this.materialRealization,
    required this.presenceLimit,
    required this.collegeType,
    this.linkMeet = '',
  });

  @override
  List<Object> get props => [
        academicPeriodId,
        subjectId,
        majorId,
        lecturerId,
        subjectClass,
        lectureSchedule,
        lectureType,
        subjectCredit,
        hourId,
        material,
        entryTime,
        approvalStatus,
        weekId,
        timeRealization,
        materialRealization,
        presenceLimit,
        collegeType,
        linkMeet,
      ];

  @override
  String toString() =>
      "CreateLectureReport{academicPeriodId: $academicPeriodId subjectId: $subjectId majorId: $majorId lecturerId: $lecturerId subjectClass: $subjectClass lectureSchedule: $lectureSchedule lectureType: $lectureType subjectCredit: $subjectCredit hourId: $hourId material: $material entryTime: $entryTime approvalStatus: $approvalStatus weekId: $weekId timeRealization: $timeRealization materialRealization: $materialRealization presenceLimit: $presenceLimit collegeType: $collegeType linkMeet: $linkMeet}";
}

class EditLectureReport extends LectureEvent {
  final String lectureId;
  final String academicPeriodId;
  final String subjectId;
  final String majorId;
  final String lecturerId;
  final String subjectClass;
  final String lectureSchedule;
  final String lectureType;
  final int subjectCredit;
  final String hourId;
  final List<Map<String, String>> material;
  final String entryTime;
  final int approvalStatus;
  final int weekId;
  final int timeRealization;
  final String materialRealization;
  final String presenceLimit;
  final int collegeType;

  const EditLectureReport({
    required this.lectureId,
    required this.academicPeriodId,
    required this.subjectId,
    required this.majorId,
    required this.lecturerId,
    required this.subjectClass,
    required this.lectureSchedule,
    required this.lectureType,
    required this.subjectCredit,
    required this.hourId,
    required this.material,
    required this.entryTime,
    required this.approvalStatus,
    required this.weekId,
    required this.timeRealization,
    required this.materialRealization,
    required this.presenceLimit,
    required this.collegeType,
  });

  @override
  List<Object> get props => [
        lectureId,
        academicPeriodId,
        subjectId,
        majorId,
        lecturerId,
        subjectClass,
        lectureSchedule,
        lectureType,
        subjectCredit,
        hourId,
        material,
        entryTime,
        approvalStatus,
        weekId,
        timeRealization,
        materialRealization,
        presenceLimit,
        collegeType,
      ];

  @override
  String toString() =>
      "EditLectureReport{lectureId: $lectureId academicPeriodId: $academicPeriodId subjectId: $subjectId majorId: $majorId lecturerId: $lecturerId subjectClass: $subjectClass lectureSchedule: $lectureSchedule lectureType: $lectureType subjectCredit: $subjectCredit hourId: $hourId material: $material entryTime: $entryTime approvalStatus: $approvalStatus weekId: $weekId timeRealization: $timeRealization materialRealization: $materialRealization presenceLimit: $presenceLimit collegeType: $collegeType";
}

class DeleteLectureReport extends LectureEvent {
  final String lectureId;

  const DeleteLectureReport({
    required this.lectureId,
  });

  @override
  List<Object> get props => [lectureId];

  @override
  String toString() => "DeleteLectureReport{lectureId: $lectureId}";
}

class GetDetailLectureReport extends LectureEvent {
  final String lectureId;

  const GetDetailLectureReport({
    required this.lectureId,
  });

  @override
  List<Object> get props => [lectureId];

  @override
  String toString() => "GetLecture{lectureId: $lectureId}";
}

class ClearStateLecture extends LectureEvent {}
