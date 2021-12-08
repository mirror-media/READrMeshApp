import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:readr/helpers/environment.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginHelper _helper = LoginHelper();

  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(LoginIng());
      bool isSuccess = false;
      try {
        if (event is EmailLogin) {
          isSuccess = await _helper.signInWithEmailAndLink(
            event.email,
            Environment().config.authlink,
          );
          if (isSuccess) {
            emit(SendEmailSuccess());
          } else {
            emit(SendEmailFailed());
          }
        } else {
          emit(MemberLoginSuccess());
        }
      } catch (e) {
        print('Login error: ${e.toString()}');
        if (event is EmailLogin) {
          emit(SendEmailFailed());
        } else {
          emit(MemberLoginFailed());
        }
      }
    });
  }
}
