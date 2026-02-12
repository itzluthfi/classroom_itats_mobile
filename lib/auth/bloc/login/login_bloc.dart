import 'package:bloc/bloc.dart';
import 'package:classroom_itats_mobile/auth/bloc/auth/auth_bloc.dart';
import 'package:classroom_itats_mobile/auth/repositories/user_repository.dart';
import 'package:classroom_itats_mobile/services/firebase_service.dart';
import 'package:equatable/equatable.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;
  final AuthBloc authBloc;

  LoginBloc({required this.userRepository, required this.authBloc})
      : super(LoginInitial()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());

      await userRepository.saveLoginInfo(event.name, event.pass);

      await AppFirebaseService().getFirebaseMessagingToken();
      try {
        final response = await userRepository.login(event.name, event.pass);
        late String token;

        if (response.statusCode != 200) {
          emit(LoginFailure(error: response.data["message"]));
        } else {
          token = response.data["token"];
          final fbt = await userRepository.getFbt();

          authBloc.add(LoggedIn(token: token, fbt: fbt));
          emit(LoginInitial());
        }
      } catch (e) {
        emit(LoginFailure(error: e.toString()));
      }
    });
  }
}
