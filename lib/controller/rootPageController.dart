import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/helpers/analyticsHelper.dart';
import 'package:readr/pages/welcomePage.dart';

class RootPageController extends GetxController {
  RootPageController();

  String minAppVersion = '0.0.1';
  bool isInitialized = false;
  var tabIndex = 0.obs;

  final prefs = Get.find<SharedPreferencesService>().prefs;

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
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    tabIndex.value = prefs.getInt('initialPageIndex') ?? 0;
    isInitialized = true;
    if (isFirstTime) {
      Get.offAll(() => WelcomePage());
    } else {
      update();
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
    if (index == 0) {
      Get.find<CommunityPageController>().scrollToTopAndRefresh();
    } else if (index == 1) {
      Get.find<LatestPageController>().scrollToTopAndRefresh();
    }
    AnalyticsHelper.logClickTab(index);
  }
}
