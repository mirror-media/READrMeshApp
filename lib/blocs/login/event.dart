part of 'bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class FacebookLogin extends LoginEvent {
  @override
  String toString() => "Facebook Login";
}

class GoogleLogin extends LoginEvent {
  @override
  String toString() => "Google Login";
}

class AppleLogin extends LoginEvent {
  @override
  String toString() => "Apple Login";
}

class EmailLogin extends LoginEvent {
  final String email;
  const EmailLogin({required this.email});
  @override
  String toString() => "Email Login";
}
