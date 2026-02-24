part of 'presensi_bloc.dart';

abstract class PresensiEvent extends Equatable {
  const PresensiEvent();

  @override
  List<Object> get props => [];
}

class LoadActivePresences extends PresensiEvent {
  final String academicPeriod;

  const LoadActivePresences(this.academicPeriod);

  @override
  List<Object> get props => [academicPeriod];
}
