import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';

class SettingPageController extends GetxController {
  SettingPageController();

  final versionAndBuildNumber = ''.obs;
  final loginType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  void initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    versionAndBuildNumber.value = 'v$version ($buildNumber)';
    loginType.value =
        Get.find<SharedPreferencesService>().prefs.getString('loginType') ?? '';
  }
}
