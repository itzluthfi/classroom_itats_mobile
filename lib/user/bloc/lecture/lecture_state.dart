part of 'lecture_bloc.dart';

sealed class LectureState extends Equatable {
  const LectureState();

  @override
  List<Object> get props => [];
}

final class LectureInitial extends LectureState {}

final class LectureLoading extends LectureState {}

final class LectureLoaded extends LectureState {
  final List<LecturePresence> lectures;
  final List<List<Lecture>> lecturerLectures;
  final List<List<LecturePresence>> responsiLectures;
  final List<Lecture> lectureReports;
  final Lecture lectureReport;

  const LectureLoaded({
    required this.lectures,
    required this.lecturerLectures,
    required this.responsiLectures,
    required this.lectureReports,
    required this.lectureReport,
  });

  @override
  List<Object> get props => [
        lectures,
        lecturerLectures,
        responsiLectures,
        lectureReports,
        lectureReport,
      ];

  @override
  String toString() =>
      "${lectures.isNotEmpty ? "${lectures.length}" : "${lecturerLectures.length}"} lectures loaded ${responsiLectures.isNotEmpty ? "and ${responsiLectures.length} responsi lecture loaded" : ""} ${lectures.isNotEmpty ? "${lectures.length} lecture loaded" : ""} ${lectureReport == Lecture() ? "" : "Lecture Report Loaded"}"; //${responsi == 0 ? "" : "subject have $responsi responsi"}
}

final class LectureLoadFailed extends LectureState {}

final class MaterialFileDownloadLoading extends LectureState {}

final class MaterialFileDownloadSuccess extends LectureState {}

final class MaterialFileDownloadFailed extends LectureState {}

final class LectureCreateLoading extends LectureState {}

final class LectureCreateSuccess extends LectureState {}

final class LectureCreateFailed extends LectureState {}

final class LectureEditLoading extends LectureState {}

final class LectureEditSuccess extends LectureState {}

final class LectureEditFailed extends LectureState {}

final class LectureDeleteLoading extends LectureState {}

final class LectureDeleteSuccess extends LectureState {}

final class LectureDeleteFailed extends LectureState {}
