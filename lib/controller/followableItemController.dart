import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
import 'package:readr/controller/personalFile/followerListController.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/controller/publisherPageController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/followableItem.dart';

class FollowableItemController extends GetxController {
  final FollowableItem item;
  FollowableItemController(this.item);

  final isFollowed = false.obs;
  bool _isError = false;

  @override
  void onInit() {
    super.onInit();
    isFollowed.value = item.isFollowed;
    debounce<bool>(
      isFollowed,
      (callback) {
        if (!_isError) {
          if (callback) {
            _updateRecommendBlock();
            addFollow();
          } else {
            removeFollow();
          }
        } else {
          _isError = false;
        }
      },
      time: const Duration(milliseconds: 300),
    );
    ever<bool>(
      isFollowed,
      (callback) {
        if (callback) {
          //update follow publisher count when onbroad
          if (Get.isRegistered<ChoosePublisherController>() &&
              item.type == FollowableItemType.publisher) {
            Get.find<ChoosePublisherController>().followedCount.value++;
          }

          //update target member personal file if exists
          if (item.type == FollowableItemType.member &&
              Get.isRegistered<PersonalFilePageController>(tag: item.id)) {
            Get.find<PersonalFilePageController>(tag: item.id)
                .followerCount
                .value++;
          }

          //update own personal file if exists
          if (Get.isRegistered<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId)) {
            Get.find<PersonalFilePageController>(
                    tag: Get.find<UserService>().currentUser.memberId)
                .followingCount
                .value++;
          }

          //update target publisher count if exists
          if (item.type == FollowableItemType.publisher &&
              Get.isRegistered<PublisherPageController>(tag: item.id)) {
            Get.find<PublisherPageController>(tag: item.id)
                .followerCount
                .value++;
          }
        } else {
          //update follow publisher count when onbroad
          if (Get.isRegistered<ChoosePublisherController>() &&
              Get.find<ChoosePublisherController>().followedCount.value > 0 &&
              item.type == FollowableItemType.publisher) {
            Get.find<ChoosePublisherController>().followedCount.value--;
          }

          //update target member personal file if exists
          if (item.type == FollowableItemType.member &&
              Get.isRegistered<PersonalFilePageController>(tag: item.id)) {
            Get.find<PersonalFilePageController>(tag: item.id)
                .followerCount
                .value--;
          }

          //update own personal file if exists
          if (Get.isRegistered<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId)) {
            Get.find<PersonalFilePageController>(
                    tag: Get.find<UserService>().currentUser.memberId)
                .followingCount
                .value--;
          }

          //update target publisher count if exists
          if (item.type == FollowableItemType.publisher &&
              Get.isRegistered<PublisherPageController>(tag: item.id)) {
            Get.find<PublisherPageController>(tag: item.id)
                .followerCount
                .value--;
          }

          //update own followingList when unfollow
          if (Get.isRegistered<FollowingListController>(
              tag: Get.find<UserService>().currentUser.memberId)) {
            final ownFollowingController = Get.find<FollowingListController>(
                tag: Get.find<UserService>().currentUser.memberId);
            if (item.type == FollowableItemType.publisher) {
              ownFollowingController.followingPublisherList
                  .removeWhere((element) => element.id == item.id);
            } else {
              ownFollowingController.followingMemberList
                  .removeWhere((element) => element.memberId == item.id);
              ownFollowingController.followingMemberCount.value--;
            }
          }
        }
      },
    );
  }

  void addFollow() async {
    bool result = await item.addFollow();
    if (!result) {
      isFollowed(false);
      _isError = true;
    } else {
      _updatePages();
    }
  }

  void removeFollow() async {
    bool result = await item.removeFollow();
    if (!result) {
      isFollowed(true);
      _isError = true;
    } else {
      _updatePages();
    }
  }

  void _updatePages() {
    _updateTargetPersonalFile();
    _updateOwnPersonalFile();
    if (item.type == FollowableItemType.member &&
        Get.find<RootPageController>().tabIndex.value == 0) {
      EasyDebounce.debounce(
          'updateCommunityPage', const Duration(milliseconds: 300), () {
        Get.find<CommunityPageController>().fetchFollowingStoryAndCollection();
      });
      EasyDebounce.debounce('updateRecommendMember', const Duration(seconds: 2),
          () {
        Get.find<RecommendMemberBlockController>().fetchRecommendMembers();
      });
    } else if (Get.find<RootPageController>().tabIndex.value == 1) {
      EasyDebounce.debounce(
          'updateLatestPage', const Duration(milliseconds: 300), () {
        Get.find<LatestPageController>().fetchLatestNews();
      });
      EasyDebounce.debounce(
          'updateRecommendPublisher', const Duration(seconds: 2), () {
        Get.find<RecommendPublisherBlockController>()
            .fetchRecommendPublishers();
      });
    } else if (Get.find<RootPageController>().tabIndex.value == 0) {
      EasyDebounce.debounce('updateRecommendMember', const Duration(seconds: 2),
          () {
        Get.find<RecommendMemberBlockController>().fetchRecommendMembers();
      });
    }
  }

  void _updateTargetPersonalFile() {
    //update target member followerList if isRegistered
    if (item.type == FollowableItemType.member &&
        Get.isRegistered<FollowerListController>(tag: item.id)) {
      Get.find<FollowerListController>(tag: item.id).fetchFollowerList();
    }

    //update target member personal file if exists
    if (item.type == FollowableItemType.member &&
        Get.isRegistered<PersonalFilePageController>(tag: item.id)) {
      Get.find<PersonalFilePageController>(tag: item.id).fetchMemberData();
    }
  }

  void _updateOwnPersonalFile() {
    if (Get.isRegistered<PersonalFilePageController>(
        tag: Get.find<UserService>().currentUser.memberId)) {
      Get.find<PersonalFilePageController>(
              tag: Get.find<UserService>().currentUser.memberId)
          .fetchMemberData();
    }
  }

  void _updateRecommendBlock() {
    if (item.type == FollowableItemType.member &&
        Get.isRegistered<RecommendMemberBlockController>()) {
      Get.find<RecommendMemberBlockController>()
          .recommendMembers
          .removeWhere((element) => element.id == item.id);
    } else if (item.type == FollowableItemType.publisher &&
        Get.isRegistered<RecommendPublisherBlockController>()) {
      Get.find<RecommendPublisherBlockController>()
          .recommendPublishers
          .removeWhere((element) => element.id == item.id);
    }
  }
}
