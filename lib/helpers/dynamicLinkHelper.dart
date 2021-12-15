import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicLinkHelper {
  final _auth = FirebaseAuth.instance;
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      final Uri? deepLink = dynamicLink.link;

      if (deepLink != null) {
        if (_auth.isSignInWithEmailLink(deepLink.toString())) {
          _loginWithEmailLink(deepLink.toString());
        }
      }
    }).onError((e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (_auth.isSignInWithEmailLink(deepLink.toString())) {
        _loginWithEmailLink(deepLink.toString());
      }
    }
  }

  _loginWithEmailLink(String emailLink) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('signInEmail') ?? "";

    // The client SDK will parse the code from the link for you.
    _auth.signInWithEmailLink(email: email, emailLink: emailLink).then((value) {
      // You can access the new user via value.user
      // Additional user info profile *not* available via:
      // value.additionalUserInfo.profile == null
      // You can check if the user is new or existing:
      // value.additionalUserInfo.isNewUser;

      print('Successfully signed in with email link!');
      Fluttertoast.showToast(
        msg: "$email登入成功",
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        fontSize: 16.0,
      );
    }).catchError((onError) async {
      print('Error signing in with email link $onError');
      Fluttertoast.showToast(
        msg: "$email登入失敗，請重新登入",
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        fontSize: 16.0,
      );
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    });
  }
}
