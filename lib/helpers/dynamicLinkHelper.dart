import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicLinkHelper {
  final _auth = FirebaseAuth.instance;
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (_auth.isSignInWithEmailLink(deepLink.toString())) {
          _loginWithEmailLink(deepLink.toString());
        }
      }
    }, onError: (OnLinkErrorException e) async {
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
    String email = prefs.getString('userEmail') ?? "";

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
    }).catchError((onError) {
      print('Error signing in with email link $onError');
    });
  }
}
