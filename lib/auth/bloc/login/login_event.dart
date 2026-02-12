part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginButtonPressed extends LoginEvent {
  final String name;
  final String pass;

  const LoginButtonPressed({required this.name, required this.pass});

  @override
  List<Object> get props => [name, pass];

  @override
  String toString() => "LoginButtonPresssed {name: $name, pass: $pass}";
}
