part of 'bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginIng extends LoginState {}

class SendEmailSuccess extends LoginState {}

class SendEmailFailed extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailed extends LoginState {}
