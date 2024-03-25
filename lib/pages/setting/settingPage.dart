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
import 'package:readr/helpers/themes.dart';
import 'package:readr/pages/setting/aboutPage.dart';
import 'package:readr/pages/setting/appearanceSettingPage.dart';
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
        title: Text(
          'setting'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Theme.of(context).extension<CustomColors>()!.primary700!,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Obx(
              () {
                if (Get.find<UserService>().isMember.isTrue) {
                  return _userInfo(context);
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
                  return _accountTile(context);
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo(BuildContext context) {
    String email = '';
    if (Get.find<UserService>().currentUser.email!.contains('[0x0001]')) {
      email = Get.find<UserService>().currentUser.nickname;
    } else {
      email = '${Get.find<UserService>().currentUser.email}';
    }
    Widget icon = Container();
    if (controller.loginType.value == 'apple') {
      icon = FaIcon(
        FontAwesomeIcons.apple,
        size: 18,
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black
            : Colors.white,
      );
    } else if (controller.loginType.value == 'facebook') {
      icon = FaIcon(
        FontAwesomeIcons.squareFacebook,
        size: 18,
        color: Theme.of(context).brightness == Brightness.light
            ? const Color.fromRGBO(59, 89, 152, 1)
            : Colors.white,
      );
    } else if (controller.loginType.value == 'google') {
      icon = SvgPicture.asset(
        googleLogoSvg,
        width: 16,
        height: 16,
        color: Theme.of(context).brightness == Brightness.light
            ? null
            : Colors.white,
      );
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).extension<CustomColors>()!.primary700!,
            ),
          ),
          icon,
        ],
      ),
    );
  }

  Widget _newsCoverageSettingButton(BuildContext context) => _settingButton(
        text: 'newsCoverageSettingPageTitle'.tr,
        onPressed: () {
          Get.to(() => NewsCoverageSettingPage());
        },
        context: context,
      );

  Widget _initialSettingButton(BuildContext context) => _settingButton(
        text: 'initialSettingPageTitle'.tr,
        onPressed: () {
          Get.to(() => InitialSettingPage());
        },
        context: context,
      );

  Widget _appearanceSettingsButton(BuildContext context) => _settingButton(
        text: 'appearance'.tr,
        onPressed: () {
          Get.to(() => AppearanceSettingPage());
        },
        context: context,
      );

  Widget _languageSettingButton(BuildContext context) => _settingButton(
        text: 'setLanguage'.tr,
        onPressed: () {
          Get.to(() => SetLanguagePage());
        },
        context: context,
      );

  Widget _contactUsButton(BuildContext context) => _settingButton(
        text: 'contactUs'.tr,
        onPressed: () {
          Get.to(() => ContactUsPage(
                appVersion: controller.versionAndBuildNumber.value,
                platform: controller.platform,
                device: controller.device,
              ));
        },
        context: context,
      );

  Widget _aboutButton(BuildContext context) => _settingButton(
        context: context,
        text: 'about'.tr,
        onPressed: () => Get.to(() => AboutPage()),
        hideArrow: true,
      );

  Widget _version(BuildContext context) => SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'version'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).extension<CustomColors>()!.primary700!,
              ),
            ),
            Obx(
              () => Text(
                controller.versionAndBuildNumber.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary500!,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _visitorSettingTile(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _newsCoverageSettingButton(context),
              const Divider(
                height: 1,
              ),
              _initialSettingButton(context),
              const Divider(
                height: 1,
              ),
              _appearanceSettingsButton(context),
              const Divider(
                height: 1,
              ),
              _languageSettingButton(context),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _contactUsButton(context),
              const Divider(
                height: 1,
              ),
              _aboutButton(context),
              const Divider(
                height: 1,
              ),
              _version(context),
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
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              _newsCoverageSettingButton(context),
              const Divider(
                height: 1,
              ),
              _initialSettingButton(context),
              const Divider(
                height: 1,
              ),
              _settingButton(
                context: context,
                text: 'blockList'.tr,
                onPressed: () {
                  Get.to(() => BlocklistPage());
                },
              ),
              const Divider(
                height: 1,
              ),
              _appearanceSettingsButton(context),
              const Divider(
                height: 1,
              ),
              _languageSettingButton(context),
            ],
          ),
        ),
        Container(
          color: Theme.of(context).backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              _contactUsButton(context),
              const Divider(
                height: 1,
              ),
              _aboutButton(context),
              const Divider(
                height: 1,
              ),
              _version(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _settingButton({
    required BuildContext context,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).extension<CustomColors>()!.primary700!,
              ),
            ),
            if (!hideArrow)
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: Theme.of(context).extension<CustomColors>()!.primary500!,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _accountTile(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color:
                      Theme.of(context).extension<CustomColors>()!.primary700!,
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
            height: 1,
          ),
          InkWell(
            child: Container(
              height: 56,
              alignment: Alignment.centerLeft,
              child: Text(
                'deletePageTitle'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).extension<CustomColors>()!.redText!,
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
