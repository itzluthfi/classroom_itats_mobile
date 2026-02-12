part of 'major_bloc.dart';

sealed class MajorEvent extends Equatable {
  const MajorEvent();

  @override
  List<Object> get props => [];
}

class GetMajor extends MajorEvent {}
