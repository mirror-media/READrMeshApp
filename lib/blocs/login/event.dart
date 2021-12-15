part of 'bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class FirebaseLoginSuccess extends LoginEvent {
  @override
  String toString() => "Firebase login success";
}

class EmailLogin extends LoginEvent {
  final String email;
  const EmailLogin({required this.email});
  @override
  String toString() => "Email Login";
}
