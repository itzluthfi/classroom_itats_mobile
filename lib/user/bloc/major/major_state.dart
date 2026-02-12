part of 'major_bloc.dart';

sealed class MajorState extends Equatable {
  const MajorState();

  @override
  List<Object> get props => [];
}

final class MajorInitial extends MajorState {}

final class MajorLoading extends MajorState {}

final class MajorLoaded extends MajorState {
  final List<Major> major;
  final String currentMajor;
  final String defaultMajor;

  const MajorLoaded({
    required this.major,
    required this.currentMajor,
    required this.defaultMajor,
  });

  @override
  List<Object> get props => [major, currentMajor, defaultMajor];

  @override
  String toString() => "${major.length} Major Loaded";
}

final class MajorLoadFailed extends MajorState {}
