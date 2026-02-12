part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  final String token;
  final String fbt;
  const LoggedIn({required this.token, required this.fbt});

  @override
  List<Object> get props => [token];

  @override
  String toString() => "LoggedIn";
}

class StoreLoginInfo extends AuthEvent {
  final String fbt;
  const StoreLoginInfo({required this.fbt});

  @override
  List<Object> get props => [fbt];

  @override
  String toString() => "StoreLoginInfo {$fbt}";
}

class LoggedOut extends AuthEvent {}
