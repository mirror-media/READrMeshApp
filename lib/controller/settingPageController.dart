import 'package:device_info_plus/device_info_plus.dart';
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
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  //information for contactUsPage
  late final String platform;
  late final String device;

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
