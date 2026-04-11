import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository userRepository;

  AuthBloc({required this.userRepository}) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final bool hasToken = await userRepository.hasToken();
      if (hasToken) {
        final token = await userRepository.getToken();

        try {
          final value = await userRepository.decodeTokenToUser(token);
          if (value.exp.compareTo(DateTime.now()) < 0) {
            emit(AuthUnauthenticated());
          } else {
            switch (value.role.trim().toLowerCase()) {
              case "mahasiswa":
                emit(AuthAuthenticated(
                    user: value, authenticatedAs: AuthenticatedAs.student));
              case "dosen":
                emit(AuthAuthenticated(
                    user: value, authenticatedAs: AuthenticatedAs.lecturer));
              default:
                emit(AuthUnauthenticated());
            }
          }
        } catch (e) {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });
    on<LoggedIn>((event, emit) async {
      emit(AuthLoading());
      await userRepository.presisteToken(event.token);
      final value = await userRepository.decodeTokenToUser(event.token);

      await userRepository.saveRoleInfo(value.role);

      var status = await userRepository.storeLoginUser(event.fbt);

      if (status != 200) {
        emit(AuthUnauthenticated());
        return;
      }

      switch (value.role.trim().toLowerCase()) {
        case "mahasiswa":
          emit(AuthAuthenticated(
              user: value, authenticatedAs: AuthenticatedAs.student));
        case "dosen":
          emit(AuthAuthenticated(
              user: value, authenticatedAs: AuthenticatedAs.lecturer));
        default:
          emit(AuthUnauthenticated());
      }
    });
    on<LoggedOut>((event, emit) async {
      emit(AuthLoading());
      try {
        var status = await userRepository.logout();

        if (status == 200) {
          await userRepository.deleteToken();
          await userRepository.deleteTempData();

          emit(AuthUnauthenticated());
        } else {
          var user = await userRepository
              .decodeTokenToUser(await userRepository.getToken());

          switch (user.role.trim().toLowerCase()) {
            case "mahasiswa":
              emit(AuthAuthenticated(
                  user: user, authenticatedAs: AuthenticatedAs.student));
            case "dosen":
              emit(AuthAuthenticated(
                  user: user, authenticatedAs: AuthenticatedAs.lecturer));
            default:
              emit(AuthUnauthenticated());
          }
        }
      } catch (e, stackTrace) {
        print(e);
        print(stackTrace);
        var user = await userRepository
            .decodeTokenToUser(await userRepository.getToken());

        switch (user.role.trim().toLowerCase()) {
          case "mahasiswa":
            emit(AuthAuthenticated(
                user: user, authenticatedAs: AuthenticatedAs.student));
          case "dosen":
            emit(AuthAuthenticated(
                user: user, authenticatedAs: AuthenticatedAs.lecturer));
          default:
            emit(AuthUnauthenticated());
        }
      }
    });
  }
}
