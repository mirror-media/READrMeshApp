import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/latestCommentBlockController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/pages/welcomePage.dart';

class RootPageController extends GetxController {
  RootPageController();

  String minAppVersion = '0.0.1';
  bool isInitialized = false;
  var tabIndex = 0.obs;
  final followingMemberUpdate = false.obs;
  final followingPublisherUpdate = false.obs;

  @override
  void onInit() {
    _initRootPage();
    debounce<bool>(
      followingMemberUpdate,
      (callback) {
        if (callback) {
          _updateMemberRelatedPages();
        }
      },
      time: const Duration(seconds: 1),
    );
    debounce<bool>(
      followingPublisherUpdate,
      (callback) {
        if (callback) {
          _updatePublisherRelatedPages();
        }
      },
      time: const Duration(seconds: 1),
    );
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
    if (index == 0) {
      Get.find<CommunityPageController>().scrollToTopAndRefresh();
    } else if (index == 1) {
      Get.find<LatestPageController>().scrollToTopAndRefresh();
    }
  }

  void _updateMemberRelatedPages() {
    //update own following list if isRegistered
    String ownId = Get.find<UserService>().currentUser.memberId;
    if (Get.isRegistered<FollowingListController>(tag: ownId)) {
      Get.find<FollowingListController>(tag: ownId).fetchFollowingList();
    }

    //update own personal file if exists
    if (Get.isRegistered<PersonalFilePageController>(tag: 'OwnPersonalFile')) {
      Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
          .fetchMemberData();
    }

    //update community page if current tab is 0
    if (tabIndex.value == 0) {
      Get.find<CommunityPageController>().updateCommunityPage();
    }

    followingMemberUpdate.value = false;
  }

  void _updatePublisherRelatedPages() {
    //update own following list if isRegistered
    String ownId = Get.find<UserService>().currentUser.memberId;
    if (Get.isRegistered<FollowingListController>(tag: ownId)) {
      Get.find<FollowingListController>(tag: ownId).fetchFollowingList();
    }

    //update own personal file if exists
    if (Get.isRegistered<PersonalFilePageController>(tag: 'OwnPersonalFile')) {
      Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
          .fetchMemberData();
    }

    //update latest page if current tab is 1
    if (tabIndex.value == 1) {
      Get.find<LatestPageController>().updateLatestNewsPage();
    } else if (tabIndex.value == 0) {
      Get.find<LatestCommentBlockController>().fetchLatestCommentNews();
      Get.find<RecommendMemberBlockController>().fetchRecommendMembers();
    }

    followingPublisherUpdate.value = false;
  }
}
