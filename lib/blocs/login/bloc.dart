import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:readr/helpers/environment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/memberService.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginHelper _helper = LoginHelper();
  final MemberService _memberService = MemberService();

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
          final FirebaseAuth _auth = FirebaseAuth.instance;
          if (event.isNewUser) {
            Member? newMember =
                await _memberService.createMember(_auth.currentUser!);
            if (newMember == null) {
              await FirebaseAuth.instance.currentUser!.delete();
              emit(MemberLoginFailed());
            } else {
              emit(MemberLoginSuccess(member: newMember));
            }
          } else {
            Member? member =
                await _memberService.fetchMemberData(_auth.currentUser!);
            emit(MemberLoginSuccess(member: member));
          }
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
