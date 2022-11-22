import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/loginMember/inputNamePage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class LoginPageController extends GetxController {
  final MemberRepos memberRepos;
  final PersonalFileRepos personalFileRepos;
  final InvitationCodeRepos invitationCodeRepos;
  LoginPageController({
    required this.memberRepos,
    required this.personalFileRepos,
    required this.invitationCodeRepos,
  });

  final List<String> publisherTitleList = [];
  final prefs = Get.find<SharedPreferencesService>().prefs;
  final isLoading = false.obs;

  @override
  void onInit() {
    _fetchPublisherTitles();
    super.onInit();
  }

  void login(LoginType type, bool isNewUser) async {
    try {
      Member? result;

      ///isNewUser is from Firebase, but sometimes may happen that the user is
      ///already logged in Firebase before, but no member data in our db.
      ///so still need to check whether db has data.
      if (!isNewUser) {
        isLoading.value = true;

        //return null if no member data that isActive with Firebase id
        result = await memberRepos.fetchMemberData().timeout(
          const Duration(minutes: 1),
          onTimeout: () {
            print('Fetch member data timeout');
            throw Exception('Fetch member data timeout');
          },
        );
      }

      if (result != null) {
        //use above result to update member data in UserService
        await Get.find<UserService>().fetchUserData(member: result);

        //check followingPublisherIds and update member data in CMS when is not empty
        final List<String> followingPublisherIds =
            prefs.getStringList('followingPublisherIds') ?? [];
        bool syncFollowingPublisherSuccess = true;
        if (followingPublisherIds.isNotEmpty) {
          await Get.find<UserService>()
              .addVisitorFollowing(followingPublisherIds)
              .timeout(
            const Duration(minutes: 1),
            onTimeout: () {
              syncFollowingPublisherSuccess = false;
            },
          );
        }

        //link linkInvitationCode with current member when invitationCodeId is not empty
        final String invitationCodeId =
            prefs.getString('invitationCodeId') ?? '';
        if (invitationCodeId.isNotEmpty) {
          invitationCodeRepos.linkInvitationCode(invitationCodeId);
        }

        //set isFirstTime to false when is true or null
        final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
        if (isFirstTime) {
          await prefs.setBool('isFirstTime', false);
        }

        //save login type for determine logo in setting page
        switch (type) {
          case LoginType.facebook:
            await prefs.setString('loginType', 'facebook');
            break;
          case LoginType.google:
            await prefs.setString('loginType', 'google');
            break;
          case LoginType.apple:
            await prefs.setString('loginType', 'apple');
            break;
        }

        isLoading.value = false;

        Fluttertoast.showToast(
          msg: 'loginSuccessToast'.tr,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0,
        );

        if (isFirstTime) {
          //restart app
          Get.offAll(RootPage());
        } else {
          Get.back();
          if (followingPublisherIds.isNotEmpty &&
              syncFollowingPublisherSuccess) {
            showFollowingSyncToast();
          } else if (followingPublisherIds.isNotEmpty &&
              !syncFollowingPublisherSuccess) {
            //try again later when update failed above
            Get.find<UserService>()
                .addVisitorFollowing(followingPublisherIds)
                .then((value) {
              showFollowingSyncToast();
            });
          }
        }
      } else {
        Get.to(() => InputNamePage(
              publisherTitleList,
              isGoogle: type == LoginType.google,
            ));
        isLoading.value = false;
      }
    } catch (e) {
      print('Login Error: $e');
      await FirebaseAuth.instance.signOut();
      Fluttertoast.showToast(
        msg: 'loginFailedToast'.tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }
  }

  //fetch to pass and use in inputNamePage
  void _fetchPublisherTitles() async {
    var publisherList = await personalFileRepos.fetchAllPublishers();
    publisherTitleList.clear();
    for (var publisher in publisherList) {
      publisherTitleList.add(publisher.title);
    }
  }
}
