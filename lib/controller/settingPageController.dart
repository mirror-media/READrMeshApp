import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/memberService.dart';

class SettingPageController extends GetxController {
  final MemberRepos memberRepos;
  SettingPageController({required this.memberRepos});

  final versionAndBuildNumber = ''.obs;
  final loginType = ''.obs;
  int duration = 24;
  final durationCheckIndex = 0.obs;
  final initialPageIndex = 0.obs;

  final prefs = Get.find<SharedPreferencesService>().prefs;
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //information for contactUsPage
  late final String platform;
  late final String device;

  //for deleteMemberPage
  final isDeleting = false.obs;
  bool deleteSuccess = false;
  bool isInitial = true;

  //for blocklistPage
  dynamic error;
  bool blocklistPageIsLoading = true;
  final List<Member> blockMembers = [];

  //for setLanguagePage
  final languageSetting = LanguageSettings.system.obs;
  String languageCode = 'system';

  //for appearanceSettingPage
  final appearanceSetting = AppearanceSettings.system.obs;
  String appearanceCode = 'system';

  @override
  void onInit() {
    super.onInit();
    debounce<int>(
      durationCheckIndex,
      (callback) async => await prefs.setInt('newsCoverage', duration),
      time: const Duration(seconds: 1),
    );
    debounce<int>(
      initialPageIndex,
      (callback) async =>
          await prefs.setInt('initialPageIndex', initialPageIndex.value),
      time: const Duration(seconds: 1),
    );
    _initialize();
  }

  void _initialize() async {
    //get package information
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    versionAndBuildNumber.value = 'v$version ($buildNumber)';

    //get device information
    if (GetPlatform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.release != null) {
        platform = 'Unknown Android Version';
      } else {
        platform = 'Android ${androidInfo.version.release}';
      }

      if (androidInfo.model != null) {
        device = androidInfo.model!;
      } else {
        device = 'Unknown device';
      }
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      String platformName;
      if (iosInfo.systemName != null) {
        platformName = iosInfo.systemName!;
        if (iosInfo.systemVersion != null) {
          platform = '$platformName ${iosInfo.systemVersion}';
        } else {
          platform = platformName;
        }
      } else {
        platform = 'Unknown platform';
      }

      if (iosInfo.utsname.machine != null) {
        device = iosInfo.utsname.machine!;
      } else {
        device = 'Unknown device';
      }
    }

    //get login type if is login
    loginType.value = prefs.getString('loginType') ?? '';

    //get news duration setting
    duration = prefs.getInt('newsCoverage') ?? 24;
    if (duration == 72) {
      durationCheckIndex.value = 1;
    } else if (duration == 168) {
      durationCheckIndex.value = 2;
    }

    //get initial page setting
    initialPageIndex.value = prefs.getInt('initialPageIndex') ?? 0;

    //get language setting
    languageCode = prefs.getString('languageSetting') ?? 'system';
    switch (languageCode) {
      case 'enUS':
        languageSetting.value = LanguageSettings.english;
        break;
      case 'zhTW':
        languageSetting.value = LanguageSettings.traditionalChinese;
        break;
      case 'zhCN':
        languageSetting.value = LanguageSettings.simplifiedChinese;
        break;
      default:
        languageSetting.value = LanguageSettings.system;
    }

    // get appearance setting
    appearanceCode = prefs.getString('appearanceSetting') ?? 'system';
    switch (appearanceCode) {
      case 'light':
        appearanceSetting.value = AppearanceSettings.light;
        break;
      case 'dark':
        appearanceSetting.value = AppearanceSettings.dark;
        break;
      default:
        appearanceSetting.value = AppearanceSettings.system;
    }
  }

  void updateDuration(int index) {
    durationCheckIndex.value = index;
    if (index == 1) {
      duration = 72;
    } else if (index == 2) {
      duration = 168;
    } else {
      duration = 24;
    }
  }

  void deleteMember() async {
    isDeleting.value = true;
    isInitial = false;
    update();
    String memberId = Get.find<UserService>().currentUser.memberId;

    try {
      await FirebaseAuth.instance.currentUser!.delete();
      await memberRepos
          .deleteMember(memberId)
          .then((value) => deleteSuccess = value);
      logDeleteAccount();
      if (deleteSuccess) {
        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          Get.delete<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId, force: true);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must reauthenticate before this operation can be executed.');
      }
      await FirebaseAuth.instance.signOut();
      deleteSuccess = false;
    } catch (e) {
      print('Delete member failed: $e');
      await FirebaseAuth.instance.signOut();
      deleteSuccess = false;
    }
    update();
    isDeleting.value = false;

    if (Get.find<SettingPageController>().loginType.value == 'google' &&
        GetPlatform.isAndroid) {
      try {
        GoogleSignIn().disconnect();
      } catch (e) {
        print('Disconnect goolge failed: $e');
      }
    }
    Get.find<HiveService>().deleteLocalMember();
  }

  void fetchBlocklist() async {
    blocklistPageIsLoading = true;
    error = null;
    update();
    try {
      if (Get.find<UserService>().currentUser.blockMemberIds != null &&
          Get.find<UserService>().currentUser.blockMemberIds!.isNotEmpty) {
        blockMembers.assignAll(await memberRepos.fetchBlockMembers(
            Get.find<UserService>().currentUser.blockMemberIds!));
      }
    } catch (e) {
      print('Fetch blocklist page failed: $e');
      error = determineException(e);
    }
    blocklistPageIsLoading = false;
    update();
  }

  void unblockMember(String blockMemberId) async {
    try {
      memberRepos.removeBlockMember(blockMemberId);
      Get.find<UserService>().removeBlockMember(blockMemberId);
      showMeshToast(
        icon: const Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.white,
        ),
        message: 'unBlockSuccess'.tr,
      );
      blockMembers.removeWhere((element) => element.memberId == blockMemberId);
      update();
    } catch (e) {
      print('Unblock member error: $e');
    }
  }

  void updateLanguage(LanguageSettings newLanguageSetting) async {
    languageSetting.value = newLanguageSetting;
    switch (newLanguageSetting) {
      case LanguageSettings.system:
        languageCode = 'system';
        await Get.updateLocale(Get.deviceLocale ?? const Locale('en'));
        break;
      case LanguageSettings.traditionalChinese:
        languageCode = 'zhTW';
        await Get.updateLocale(const Locale('zh', 'TW'));
        break;
      case LanguageSettings.simplifiedChinese:
        languageCode = 'zhCN';
        await Get.updateLocale(const Locale('zh', 'CN'));
        break;
      case LanguageSettings.english:
        languageCode = 'enUS';
        await Get.updateLocale(const Locale('en', 'US'));
        break;
    }

    if (Get.isRegistered<PersonalFilePageController>(
        tag: Get.find<UserService>().currentUser.memberId)) {
      Get.find<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId)
          .updateTabs();
    }
    await prefs.setString('languageSetting', languageCode);
  }

  void updateAppearance(AppearanceSettings newAppearanceSetting) async {
    appearanceSetting.value = newAppearanceSetting;
    switch (newAppearanceSetting) {
      case AppearanceSettings.system:
        appearanceCode = 'system';
        Get.changeThemeMode(ThemeMode.system);
        break;
      case AppearanceSettings.light:
        appearanceCode = 'light';
        Get.changeThemeMode(ThemeMode.light);
        break;
      case AppearanceSettings.dark:
        appearanceCode = 'dark';
        Get.changeThemeMode(ThemeMode.dark);
        break;
    }

    await prefs.setString('appearanceSetting', appearanceCode);
  }
}
