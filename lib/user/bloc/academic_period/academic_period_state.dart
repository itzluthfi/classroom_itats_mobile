part of 'academic_period_bloc.dart';

sealed class AcademicPeriodState extends Equatable {
  const AcademicPeriodState();

  @override
  List<Object> get props => [];
}

final class AcademicPeriodInitial extends AcademicPeriodState {}

final class AcademicPeriodLoading extends AcademicPeriodState {}

final class AcademicPeriodLoaded extends AcademicPeriodState {
  final List<AcademicPeriod> academicPeriod;
  final String activeAcademicPeriod;
  final String currentAcademicPeriod;

  const AcademicPeriodLoaded({
    required this.academicPeriod,
    required this.activeAcademicPeriod,
    required this.currentAcademicPeriod,
  });

  @override
  List<Object> get props => [academicPeriod];

  @override
  String toString() =>
      "${academicPeriod.length} AcademicPeriod Loaded with AcademicPeriod $currentAcademicPeriod";
}

final class AcademicPeriodLoadFailed extends AcademicPeriodState {}
