import 'package:bloc/bloc.dart';

class ClassroomItatsMobileObserver extends BlocObserver {
  const ClassroomItatsMobileObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    // ignore: avoid_print
    print('onChange: ${bloc.runtimeType} $change');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);

    // ignore: avoid_print
    print('onEvent: ${bloc.runtimeType} $event');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);

    // ignore: avoid_print
    print('onTransition: ${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    // ignore: avoid_print
    print('onError:  ${bloc.runtimeType} $error, $stackTrace');
  }
}
