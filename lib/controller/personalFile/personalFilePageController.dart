import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:readr/controller/followableItemController.dart';
import 'package:readr/controller/settingPageController.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/personalFile/bookmarkTabContent.dart';
import 'package:readr/pages/personalFile/collectionTabContent.dart';
import 'package:readr/pages/personalFile/deletedMemberPage.dart';
import 'package:readr/pages/personalFile/pickTabContent.dart';
import 'package:readr/pages/shared/meshToast.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';

class PersonalFilePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PersonalFileRepos personalFileRepos;
  final MemberRepos memberRepos;
  Member viewMember;
  PersonalFilePageController({
    required this.personalFileRepos,
    required this.memberRepos,
    required this.viewMember,
  });

  static PersonalFilePageController get to => Get.find();

  late final Rx<Member> viewMemberData;
  final pickCount = 0.obs;
  final followerCount = 0.obs;
  final followingCount = 0.obs;
  final bookmarkCount = 0.obs;

  final isLoading = true.obs;
  final isError = false.obs;
  dynamic error;

  late TabController tabController;
  final List<Tab> tabs = [];
  final List<Widget> tabWidgets = [];

  final JustTheController tooltipController = JustTheController();

  final isBlock = false.obs;

  @override
  void onInit() {
    viewMemberData = Rx<Member>(viewMember);
    if (Get.find<UserService>().isBlockMember(viewMember.memberId)) {
      isBlock.value = true;
    }
    initPage();
    super.onInit();
  }

  @override
  void onReady() {
    if (Get.find<UserService>().isBlocked(viewMember.memberId)) {
      Get.off(() => DeletedMemberPage());
    }
    super.onReady();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void initPage() async {
    isLoading.value = true;
    isError.value = false;
    try {
      await fetchMemberData();
      _initializeTabController();
      isLoading.value = false;
    } catch (e) {
      print('Fetch personal file error: $e');
      error = determineException(e);
      isError.value = true;
    }
  }

  Future<void> fetchMemberData() async {
    await Future.wait([
      personalFileRepos
          .fetchMemberData(viewMember)
          .then((value) => viewMemberData.value = value),
    ]);

    pickCount.value = viewMemberData.value.pickCount ?? 0;
    followerCount.value = viewMemberData.value.followerCount ?? 0;
    int followingMemberCount = viewMemberData.value.followingCount ?? 0;
    int followingPublisherCount =
        viewMemberData.value.followingPublisherCount ?? 0;
    followingCount.value = followingMemberCount + followingPublisherCount;
    bookmarkCount.value = viewMemberData.value.bookmarkCount ?? 0;
  }

  void _initializeTabController() {
    tabs.clear();
    tabWidgets.clear();

    tabs.add(
      Tab(
        child: Text(
          'picks'.tr,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );

    tabWidgets.add(PickTabContent(
      viewMember: viewMemberData.value,
    ));

    if (Get.find<UserService>().showCollectionTooltip &&
        viewMemberData.value.memberId ==
            Get.find<UserService>().currentUser.memberId) {
      Future.delayed(const Duration(seconds: 1), () {
        try {
          tooltipController.showTooltip();
        } catch (e) {
          // Ignore controller not been attached error.
        }
      });
    }

    tabs.add(
      Tab(
        child: Text(
          'collections'.tr,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );

    tabWidgets.add(CollectionTabContent(
      viewMember: viewMemberData.value,
    ));

    if (viewMemberData.value.memberId ==
        Get.find<UserService>().currentUser.memberId) {
      tabs.add(
        Tab(
          child: Text(
            'bookmarks'.tr,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );

      tabWidgets.add(BookmarkTabContent());
    }

    // set controller
    tabController = TabController(
      vsync: this,
      length: tabs.length,
    );

    tabController.addListener(() {
      if (tabController.index == 1) {
        tooltipController.hideTooltip();
        Get.find<UserService>().showCollectionTooltip = false;
        Get.find<HiveService>().tooltipBox.put('showCollectionTooltip', false);
      }
    });
  }

  void blockMember() async {
    try {
      memberRepos.addBlockMember(viewMember.memberId);
      Get.find<UserService>().addBlockMember(viewMember.memberId);
      Get.find<UserService>().removeFollowingMember(viewMember.memberId);
      Get.find<FollowableItemController>(
              tag: MemberFollowableItem(viewMemberData.value).tag)
          .isFollowed
          .value = false;
      isBlock.value = true;
      _showResultToast('blockSuccess'.tr);
      if (Get.isRegistered<SettingPageController>()) {
        Get.find<SettingPageController>().fetchBlocklist();
      }
    } catch (e) {
      print('Block member error: $e');
    }
  }

  void unblockMember() async {
    try {
      memberRepos.removeBlockMember(viewMember.memberId);
      Get.find<UserService>().removeBlockMember(viewMember.memberId);
      isBlock.value = false;
      _showResultToast('unBlockSuccess'.tr);
      if (Get.isRegistered<SettingPageController>()) {
        final settingPageController = Get.find<SettingPageController>();
        settingPageController.blockMembers
            .removeWhere((element) => element.memberId == viewMember.memberId);
        settingPageController.update();
      }
    } catch (e) {
      print('Unblock member error: $e');
    }
  }

  void _showResultToast(String message) {
    showMeshToast(
      icon: const Icon(
        Icons.check_circle,
        size: 16,
        color: Colors.white,
      ),
      message: message,
    );
  }
}
