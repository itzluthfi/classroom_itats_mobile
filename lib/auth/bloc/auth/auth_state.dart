part of 'auth_bloc.dart';

enum AuthenticatedAs { student, lecturer }

@immutable
sealed class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthAuthenticated extends AuthState {
  final User user;
  final AuthenticatedAs authenticatedAs;

  AuthAuthenticated({required this.user, required this.authenticatedAs});

  @override
  List<Object> get props => [user, authenticatedAs];
}

final class AuthUnauthenticated extends AuthState {}

final class AuthLoading extends AuthState {}
