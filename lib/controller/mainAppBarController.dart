import 'dart:async';

import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/services/invitationCodeService.dart';

class MainAppBarController extends GetxController {
  final InvitationCodeRepos invitationCodeService;
  MainAppBarController(this.invitationCodeService);

  final hasInvitationCode = false.obs;
  late final Timer timer;

  @override
  void onInit() {
    checkInvitationCode();
    super.onInit();
  }

  void checkInvitationCode() async {
    if (Get.find<UserService>().isMember.isTrue) {
      hasInvitationCode.value =
          await invitationCodeService.checkUsableInvitationCode(
              Get.find<UserService>().currentUser.memberId);
    }
  }
}
