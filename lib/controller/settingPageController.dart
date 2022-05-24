import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';

class SettingPageController extends GetxController {
  SettingPageController();

  final versionAndBuildNumber = ''.obs;
  final loginType = ''.obs;
  int duration = 24;
  final durationCheckIndex = 0.obs;
  final initialPageIndex = 0.obs;

  final prefs = Get.find<SharedPreferencesService>().prefs;

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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    versionAndBuildNumber.value = 'v$version ($buildNumber)';
    loginType.value = prefs.getString('loginType') ?? '';
    duration = prefs.getInt('newsCoverage') ?? 24;
    if (duration == 72) {
      durationCheckIndex.value = 1;
    } else if (duration == 168) {
      durationCheckIndex.value = 2;
    }
    initialPageIndex.value = prefs.getInt('initialPageIndex') ?? 0;
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
}
