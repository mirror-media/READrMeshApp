import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/pages/welcomePage.dart';

class RootPageController extends GetxController {
  RootPageController();

  String minAppVersion = '0.0.1';
  bool isInitialized = false;
  var tabIndex = 0.obs;
  var isVisitor = Get.find<UserService>().isVisitor.obs;

  @override
  void onInit() {
    _initRootPage();
    super.onInit();
  }

  void _initRootPage() async {
    FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    remoteConfig.setDefaults(<String, dynamic>{'min_version_number': '0.0.1'});
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await remoteConfig.fetchAndActivate();
    minAppVersion = remoteConfig.getString('min_version_number');
    bool isFirstTime =
        Get.find<SharedPreferencesService>().prefs.getBool('isFirstTime') ??
            true;
    isInitialized = true;
    if (isFirstTime) {
      Get.offAll(() => WelcomePage());
    } else {
      update();
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
