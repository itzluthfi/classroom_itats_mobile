part of 'presence_bloc.dart';

sealed class PresenceState extends Equatable {
  const PresenceState();

  @override
  List<Object> get props => [];
}

final class PresenceInitial extends PresenceState {}

final class PresenceLoading extends PresenceState {}

final class PresenceLoaded extends PresenceState {
  final List<Presence> presences;
  final List<PresenceQuestion> presenceQuestions;

  const PresenceLoaded(
      {required this.presences, required this.presenceQuestions});

  @override
  List<Object> get props => [presences, presenceQuestions];

  @override
  String toString() =>
      "${presences.isNotEmpty ? "${presences.length} presence loaded" : ""} ${presenceQuestions.isNotEmpty ? "${presenceQuestions.length} presence question loaded" : ""}";
}

final class PresenceLoadFailed extends PresenceState {}

final class CreatePresenceLoading extends PresenceState {}

final class CreatePresenceSuccess extends PresenceState {}

final class CreatePresenceFailed extends PresenceState {}
