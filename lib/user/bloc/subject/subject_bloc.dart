import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/models/subject.dart';
import 'package:classroom_itats_mobile/user/repositories/academic_period_repository.dart';
import 'package:classroom_itats_mobile/user/repositories/subject_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository subjectRepository;
  final AcademicPeriodRepository academicPeriodRepository;

  SubjectBloc(
      {required this.subjectRepository, required this.academicPeriodRepository})
      : super(SubjectInitial()) {
    on<GetSubject>((event, emit) async {
      emit(SubjectLoading());
      try {
        final List<Subject> subjects = await subjectRepository.getSubjects();

        final data =
            await subjectRepository.subjectView(subjects, event.context);
        emit(SubjectLoaded(
            data: data, subjects: subjects, subjectReports: List.empty()));
      } catch (e) {
        emit(SubjectLoadFailed());
      }
    });
    on<FilterButtonPressed>((event, emit) async {
      emit(SubjectLoading());
      try {
        final subjects = await subjectRepository.getSubjectsFiltered(
            event.academicPeriod, event.major);
        final data =
            await subjectRepository.subjectView(subjects, event.context);
        emit(SubjectLoaded(
            data: data, subjects: subjects, subjectReports: List.empty()));
      } catch (e) {
        emit(SubjectLoadFailed());
      }
    });
    on<GetSubjectReport>((event, emit) async {
      emit(SubjectLoading());
      try {
        final List<SubjectReport> subjects =
            await subjectRepository.getSubjectReports();

        final data =
            await subjectRepository.subjectReportView(subjects, event.context);
        emit(SubjectLoaded(
            data: data, subjects: List.empty(), subjectReports: subjects));
      } catch (e) {
        emit(SubjectLoadFailed());
      }
    });
    on<FilterButtonPressedReport>((event, emit) async {
      emit(SubjectLoading());
      try {
        final subjects = await subjectRepository.getSubjectReportsFiltered(
            event.academicPeriod, event.major);
        final data =
            await subjectRepository.subjectReportView(subjects, event.context);
        emit(SubjectLoaded(
            data: data, subjects: List.empty(), subjectReports: subjects));
      } catch (e) {
        emit(SubjectLoadFailed());
      }
    });
  }
}
