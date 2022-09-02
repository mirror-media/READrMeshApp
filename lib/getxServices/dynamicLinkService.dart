import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/collection/collectionDeletedPage.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/loginMember/inputNamePage.dart';
import 'package:readr/pages/personalFile/deletedMemberPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/collectionService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicLinkService extends GetxService {
  final _auth = FirebaseAuth.instance;
  Future<DynamicLinkService> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      _checkLink(dynamicLink);
    }).onError((e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _checkLink(data);

    return this;
  }

  void _checkLink(PendingDynamicLinkData? data) {
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (_auth.isSignInWithEmailLink(deepLink.toString())) {
        _loginWithEmailLink(deepLink.toString());
      } else if (deepLink.toString().contains('collection?=')) {
        _openCollectionLink(data!);
      } else if (deepLink.toString().contains('member?=')) {
        _openPersonalFileLink(data!);
      }
    }
  }

  _loginWithEmailLink(String emailLink) async {
    SharedPreferences prefs = Get.find<SharedPreferencesService>().prefs;
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
      await prefs.setString('loginType', 'email');
      if (value.additionalUserInfo!.isNewUser) {
        List<String> publisherTitleList = await _fetchPublisherTitles();
        Get.to(() => InputNamePage(publisherTitleList));
      } else {
        var result = await MemberService().fetchMemberData();
        if (result != null) {
          Fluttertoast.showToast(
            msg: "loginSuccessToast".tr,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0,
          );
          final List<String> followingPublisherIds =
              prefs.getStringList('followingPublisherIds') ?? [];
          if (followingPublisherIds.isNotEmpty) {
            Fluttertoast.showToast(
              msg: "syncingFollowingPublisherToast".tr,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              fontSize: 16.0,
            );
            await Get.find<UserService>()
                .addVisitorFollowing(followingPublisherIds)
                .timeout(
              const Duration(minutes: 1),
              onTimeout: () {
                Get.find<UserService>().fetchUserData(member: result);
              },
            );
          } else {
            Get.find<UserService>().fetchUserData(member: result);
          }

          final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
          if (isFirstTime) {
            Get.offAll(RootPage());
            await prefs.setBool('isFirstTime', false);
          } else {
            if (Get.currentRoute != '/') {
              Get.until((route) => Get.currentRoute != '/LoginPage');
            }

            if (followingPublisherIds.isNotEmpty) {
              showFollowingSyncToast();
            }
          }
        } else {
          List<String> publisherTitleList = await _fetchPublisherTitles();
          Get.to(() => InputNamePage(publisherTitleList));
        }
      }
    }).catchError((onError) async {
      print('Error signing in with email link $onError');
      Fluttertoast.showToast(
        msg: "loginFailedToast".tr,
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

  void _openCollectionLink(PendingDynamicLinkData dynamicLinkData) async {
    // check app verison first
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    bool versionCheck = true;
    if (GetPlatform.isIOS && dynamicLinkData.ios != null) {
      versionCheck = _isVersionGreaterThan(
          packageInfo.version, dynamicLinkData.ios!.minimumVersion ?? '1.2.0');
    }

    Collection? collection;
    try {
      if (versionCheck) {
        String link = dynamicLinkData.link.toString();
        int startIndex = link.indexOf('=') + 1;
        String collectionId = link.substring(startIndex);
        collection =
            await CollectionService().fetchCollectionById(collectionId);
      } else {
        Fluttertoast.showToast(
          msg: "updateAppToast".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Open collection link error: $e');
    }

    if (collection != null && collection.status != CollectionStatus.delete) {
      Get.to(
        () => CollectionPage(collection!),
      );
    } else if (collection != null) {
      Get.to(() => const CollectionDeletedPage());
    } else {
      Fluttertoast.showToast(
        msg: "openLinkFailedToast".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _openPersonalFileLink(PendingDynamicLinkData dynamicLinkData) async {
    // check app verison first
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    bool versionCheck = true;
    if (GetPlatform.isIOS && dynamicLinkData.ios != null) {
      versionCheck = _isVersionGreaterThan(
          packageInfo.version, dynamicLinkData.ios!.minimumVersion ?? '1.2.0');
    }

    Member? member;
    try {
      if (versionCheck) {
        String link = dynamicLinkData.link.toString();
        int startIndex = link.indexOf('=') + 1;
        String memberId = link.substring(startIndex);
        member = await MemberService().fetchMemberDataById(memberId);
      } else {
        Fluttertoast.showToast(
          msg: "updateAppToast".tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Open collection link error: $e');
    }

    if (member != null && !Get.find<UserService>().isBlocked(member.memberId)) {
      Get.to(
        () => PersonalFilePage(
          viewMember: member!,
        ),
      );
    } else {
      Get.to(
        () => DeletedMemberPage(),
      );
    }
  }

  bool _isVersionGreaterThan(String currentVersion, String minVersion) {
    List<String> minV = minVersion.split(".");
    List<String> nowV = currentVersion.split(".");
    bool a = false;
    for (var i = 0; i <= 2; i++) {
      a = int.parse(nowV[i]) > int.parse(minV[i]);
      if (int.parse(nowV[i]) != int.parse(minV[i])) break;
    }
    return a;
  }
}
