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
      try {
        if (event is EmailLogin) {
          bool isSuccess = await _helper.signInWithEmailAndLink(
            event.email,
            Environment().config.authlink,
          );
          if (isSuccess) {
            emit(SendEmailSuccess());
          } else {
            emit(SendEmailFailed());
          }
        } else if (event is FirebaseLoginSuccess) {
          emit(const MemberLoginSuccess());
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
