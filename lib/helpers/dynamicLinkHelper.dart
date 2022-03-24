import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicLinkHelper {
  final _auth = FirebaseAuth.instance;
  void initDynamicLinks(BuildContext context) async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      final Uri? deepLink = dynamicLink.link;

      if (deepLink != null) {
        if (_auth.isSignInWithEmailLink(deepLink.toString())) {
          _loginWithEmailLink(context, deepLink.toString());
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
        _loginWithEmailLink(context, deepLink.toString());
      }
    }
  }

  _loginWithEmailLink(BuildContext context, String emailLink) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('signInEmail') ?? "";

    // The client SDK will parse the code from the link for you.
    _auth
        .signInWithEmailLink(email: email, emailLink: emailLink)
        .then((value) async {
      // You can access the new user via value.user
      // Additional user info profile *not* available via:
      // value.additionalUserInfo.profile == null
      // You can check if the user is new or existing:
      // value.additionalUserInfo.isNewUser;

      print('Successfully signed in with email link!');
      if (value.additionalUserInfo!.isNewUser) {
        AutoRouter.of(context).replace(
            InputNameRoute(publisherTitleList: await _fetchPublisherTitles()));
      } else {
        var result = await MemberService().fetchMemberData();
        if (result != null) {
          await UserHelper.instance.fetchUserData();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isFirstTime', false);
          await prefs.setString('loginType', 'email');
          AutoRouter.of(context)
              .pushAndPopUntil(const Initial(), predicate: (route) => false);
        } else {
          AutoRouter.of(context).replace(InputNameRoute(
              publisherTitleList: await _fetchPublisherTitles()));
        }
      }
    }).catchError((onError) async {
      print('Error signing in with email link $onError');
      Fluttertoast.showToast(
        msg: "登入失敗，請重新登入",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<List<String>> _fetchPublisherTitles() async {
    var publisherList = await PersonalFileService().fetchAllPublishers();
    List<String> publisherTitleList = [];
    for (var publisher in publisherList) {
      publisherTitleList.add(publisher.title);
    }
    return publisherTitleList;
  }
}
