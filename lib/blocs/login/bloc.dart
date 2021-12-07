import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/helpers/environment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  LoginBloc() : super(LoginInitial()) {
    on<LoginEvent>((event, emit) async {
      emit(LoginIng());
      bool isSuccess = false;
      try {
        if (event is EmailLogin) {
          isSuccess = await _signInWithEmailAndLink(event.email);
        } else if (event is GoogleLogin) {
          isSuccess = await _signInWithGoogle();
        } else if (event is FacebookLogin) {
          isSuccess = await _signInWithFacebook();
        } else if (event is AppleLogin) {
          isSuccess = await _signInWithApple();
        }

        if (event is EmailLogin && isSuccess) {
          emit(SendEmailSuccess());
        } else if (event is EmailLogin && !isSuccess) {
          emit(SendEmailFailed());
        } else if (isSuccess) {
          emit(LoginSuccess());
        } else {
          emit(LoginFailed());
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

  Future<bool> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

      return true;
    } catch (e) {
      print('SignInWithGoogle failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> _signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential credential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);
        // Once signed in, return the UserCredential
        await FirebaseAuth.instance.signInWithCredential(credential);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('SignInWithFacebook failed: ${e.toString()}');
      return false;
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      return true;
    } catch (e) {
      return false;
    }
  }
}
