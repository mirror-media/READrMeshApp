import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/helpers/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(LoginIng());
      try {
        if (event is EmailLogin) {
          bool isSuccess = await _signInWithEmailAndLink(event.email);
          if (isSuccess) {
            emit(SendEmailSuccess());
          } else {
            emit(LoginFailed());
          }
        }
      } catch (e) {
        print('Login error: ${e.toString()}');
        if (event is EmailLogin) {
          emit(SendEmailFailed());
        } else {
          emit(LoginFailed());
        }
      }
    });
  }

  Future<bool> _signInWithEmailAndLink(String email) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var acs = ActionCodeSettings(
      // URL you want to redirect back to. The domain (www.example.com) for this
      // URL must be whitelisted in the Firebase Console.
      url: Environment().config.authlink,
      // This must be true
      handleCodeInApp: true,
      iOSBundleId: packageInfo.packageName,
      androidPackageName: packageInfo.packageName,
      // installIfNotAvailable
      androidInstallApp: true,
    );

    bool isSuccess = false;
    await _auth
        .sendSignInLinkToEmail(email: email, actionCodeSettings: acs)
        .catchError((onError) {
      print('Error sending email verification $onError');
    }).then((value) async {
      print('Successfully sent email verification');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', email);
      isSuccess = true;
    });
    return isSuccess;
  }
}
