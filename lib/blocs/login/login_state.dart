part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class Loading extends LoginState {}

class ExistingMemberLogin extends LoginState {}

class NewMemberSignup extends LoginState {
  final List<String> publisherTitleList;
  const NewMemberSignup(this.publisherTitleList);
}

class LoginError extends LoginState {}
