part of 'academic_period_bloc.dart';

sealed class AcademicPeriodEvent extends Equatable {
  const AcademicPeriodEvent();

  @override
  List<Object> get props => [];
}

class GetAcademicPeriod extends AcademicPeriodEvent {}
