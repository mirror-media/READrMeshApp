import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/pages/setting/aboutPage.dart';
import 'package:readr/pages/setting/blocklistPage.dart';
import 'package:readr/pages/setting/contactUsPage.dart';
import 'package:readr/pages/setting/deleteMemberPage.dart';
import 'package:readr/pages/setting/initialSettingPage.dart';
import 'package:readr/pages/setting/newsCoverageSettingPage.dart';
import 'package:readr/pages/setting/setLanguagePage.dart';
import 'package:readr/services/memberService.dart';

class SettingPage extends GetView<SettingPageController> {
  @override
  Widget build(BuildContext context) {
    Get.put(SettingPageController(memberRepos: MemberService()));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(
          'setting'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: readrBlack,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Obx(
              () {
                if (Get.find<UserService>().isMember.isTrue) {
                  return _userInfo();
                }
                return Container();
              },
            ),
            Obx(
              () {
                if (Get.find<UserService>().isMember.isTrue) {
                  return _memberSettingTile(context);
                }
                return _visitorSettingTile(context);
              },
            ),
            Obx(
              () {
                if (Get.find<UserService>().isMember.isTrue) {
                  return _accountTile();
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    String email = '';
    if (Get.find<UserService>().currentUser.email!.contains('[0x0001]')) {
      email = Get.find<UserService>().currentUser.nickname;
    } else {
      email = '${Get.find<UserService>().currentUser.email}';
    }
    Widget icon = Container();
    if (controller.loginType.value == 'apple') {
      icon = const FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: readrBlack,
      );
    } else if (controller.loginType.value == 'facebook') {
      icon = const FaIcon(
        FontAwesomeIcons.squareFacebook,
        size: 18,
        color: Color.fromRGBO(59, 89, 152, 1),
      );
    } else if (controller.loginType.value == 'google') {
      icon = SvgPicture.asset(
        googleLogoSvg,
        width: 16,
        height: 16,
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: readrBlack87,
            ),
          ),
          icon,
        ],
      ),
    );
  }

  Widget _visitorSettingTile(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _settingButton(
                text: 'newsCoverageSettingPageTitle'.tr,
                onPressed: () {
                  Get.to(() => NewsCoverageSettingPage());
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'initialSettingPageTitle'.tr,
                onPressed: () {
                  Get.to(() => InitialSettingPage());
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'setLanguage'.tr,
                onPressed: () {
                  Get.to(() => SetLanguagePage());
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _settingButton(
                text: 'contactUs'.tr,
                onPressed: () {
                  Get.to(() => ContactUsPage(
                        appVersion: controller.versionAndBuildNumber.value,
                        platform: controller.platform,
                        device: controller.device,
                      ));
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'about'.tr,
                onPressed: () => Get.to(() => AboutPage()),
                hideArrow: true,
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'version'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: readrBlack87,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.versionAndBuildNumber.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: readrBlack50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _memberSettingTile(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              _settingButton(
                text: 'newsCoverageSettingPageTitle'.tr,
                onPressed: () {
                  Get.to(() => NewsCoverageSettingPage());
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'initialSettingPageTitle'.tr,
                onPressed: () {
                  Get.to(() => InitialSettingPage());
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'blockList'.tr,
                onPressed: () {
                  Get.to(() => BlocklistPage());
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'setLanguage'.tr,
                onPressed: () {
                  Get.to(() => SetLanguagePage());
                },
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              _settingButton(
                text: 'contactUs'.tr,
                onPressed: () {
                  Get.to(() => ContactUsPage(
                        appVersion: controller.versionAndBuildNumber.value,
                        platform: controller.platform,
                        device: controller.device,
                      ));
                },
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              _settingButton(
                text: 'about'.tr,
                onPressed: () => Get.to(() => AboutPage()),
                hideArrow: true,
              ),
              const Divider(
                color: readrBlack10,
                height: 1,
              ),
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'version'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: readrBlack87,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.versionAndBuildNumber.value,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: readrBlack50,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingButton({
    required String text,
    void Function()? onPressed,
    bool hideArrow = false,
  }) {
    return SizedBox(
      height: 56,
      child: InkWell(
        onTap: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: readrBlack87,
              ),
            ),
            if (!hideArrow)
              const Icon(
                Icons.arrow_forward_ios_outlined,
                color: readrBlack50,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _accountTile() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: Text(
                'logOut'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: readrBlack87,
                ),
              ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (Get.isRegistered<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId)) {
                Get.delete<PersonalFilePageController>(
                    tag: Get.find<UserService>().currentUser.memberId,
                    force: true);
              }
              if (controller.loginType.value == 'google' &&
                  GetPlatform.isAndroid) {
                GoogleSignIn().disconnect();
              }
              Get.find<HiveService>().deleteLocalMember();
              await Get.find<UserService>().fetchUserData();
            },
          ),
          const Divider(
            color: readrBlack10,
            height: 1,
          ),
          InkWell(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: Text(
                'deletePageTitle'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              ),
            ),
            onTap: () {
              Get.to(() => DeleteMemberPage());
            },
          ),
        ],
      ),
    );
  }
}
