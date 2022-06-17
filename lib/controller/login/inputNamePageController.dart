import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/pages/loginMember/chooseMemberPage.dart';
import 'package:readr/pages/loginMember/choosePublisherPage.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/memberService.dart';

class InputNamePageController extends GetxController {
  final MemberRepos memberRepos;
  InputNamePageController({
    required this.memberRepos,
  });

  final isCreating = false.obs;
  final TextEditingController textController = TextEditingController(
      text: FirebaseAuth.instance.currentUser!.displayName);

  void createMember() async {
    isCreating.value = true;
    try {
      await MemberService().createMember(textController.text).timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw Exception();
        },
      );
      final prefs = Get.find<SharedPreferencesService>().prefs;

      final String invitationCodeId = prefs.getString('invitationCodeId') ?? '';
      if (invitationCodeId.isNotEmpty) {
        await InvitationCodeService().linkInvitationCode(invitationCodeId);
      }

      final List<String> followingPublisherIds =
          prefs.getStringList('followingPublisherIds') ?? [];
      if (followingPublisherIds.isNotEmpty) {
        Get.off(() => const ChooseMemberPage(false));
      } else {
        Get.off(() => ChoosePublisherPage());
      }
      AnalyticsHelper.logSignUp();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "發生錯誤，請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }
    isCreating.value = false;
  }
}
