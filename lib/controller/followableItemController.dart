import 'package:get/get.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
import 'package:readr/controller/personalFile/followerListController.dart';
import 'package:readr/controller/personalFile/followingListController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/models/followableItem.dart';

class FollowableItemController extends GetxController {
  final FollowableItem item;
  FollowableItemController(this.item);

  final isFollowed = false.obs;
  final _isSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    isFollowed.value = item.isFollowed;
    debounce<bool>(
      isFollowed,
      (callback) {
        if (callback) {
          addFollow();
        } else {
          removeFollow();
        }
      },
      time: const Duration(milliseconds: 500),
    );
    debounce<bool>(
      _isSuccess,
      (callback) {
        if (callback) {
          _updatePersonalFile();
        }
      },
      time: const Duration(seconds: 5),
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
        } else {
          //update follow publisher count when onbroad
          if (Get.isRegistered<ChoosePublisherController>() &&
              Get.find<ChoosePublisherController>().followedCount.value > 0 &&
              item.type == FollowableItemType.publisher) {
            Get.find<ChoosePublisherController>().followedCount.value--;
          }
        }
      },
    );
  }

  void addFollow() async {
    bool result = await item.addFollow();
    if (!result) {
      isFollowed(false);
    } else {
      _isSuccess.value = true;
    }
  }

  void removeFollow() async {
    bool result = await item.removeFollow();
    if (!result) {
      isFollowed(true);
    } else {
      _isSuccess.value = true;
    }
  }

  void _updatePersonalFile() {
    //update own following list if isRegistered
    String ownId = Get.find<UserService>().currentUser.memberId;
    if (Get.isRegistered<FollowingListController>(tag: ownId)) {
      Get.find<FollowingListController>(tag: ownId).fetchFollowingList();
    }

    //update target member followerList if isRegistered
    if (item.type == FollowableItemType.member &&
        Get.isRegistered<FollowerListController>(tag: item.id)) {
      Get.find<FollowerListController>(tag: item.id).fetchFollowerList();
    }

    //update own personal file if exists
    if (Get.isRegistered<PersonalFilePageController>(tag: 'OwnPersonalFile')) {
      Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
          .fetchMemberData();
    }

    //update target member personal file if exists
    if (item.type == FollowableItemType.member &&
        Get.isRegistered<PersonalFilePageController>(tag: item.id)) {
      Get.find<PersonalFilePageController>(tag: item.id).fetchMemberData();
    }
  }
}
