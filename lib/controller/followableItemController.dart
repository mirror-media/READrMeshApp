import 'package:get/get.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/models/followableItem.dart';

class FollowableItemController extends GetxController {
  final FollowableItem item;
  FollowableItemController(this.item);

  final isFollowed = false.obs;

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
    ever<bool>(
      isFollowed,
      (callback) {
        if (callback) {
          //update follow publisher count when onbroad
          if (Get.isRegistered<ChoosePublisherController>() &&
              item.type == FollowableItemType.publisher) {
            Get.find<ChoosePublisherController>().followedCount.value++;
          }

          //update own personal file if exists
          if (Get.isRegistered<PersonalFilePageController>(
              tag: 'OwnPersonalFile')) {
            Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
                .followingCount
                .value++;
          }

          //update target member personal file if exists
          if (item.type == FollowableItemType.member &&
              Get.isRegistered<PersonalFilePageController>(tag: item.id)) {
            Get.find<PersonalFilePageController>(tag: item.id)
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

          //update own personal file if exists
          if (Get.isRegistered<PersonalFilePageController>(
                  tag: 'OwnPersonalFile') &&
              Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
                      .followingCount
                      .value >
                  0) {
            Get.find<PersonalFilePageController>(tag: 'OwnPersonalFile')
                .followingCount
                .value--;
          }

          //update target member personal file if exists
          if (item.type == FollowableItemType.member &&
              Get.isRegistered<PersonalFilePageController>(tag: item.id) &&
              Get.find<PersonalFilePageController>(tag: item.id)
                      .followerCount
                      .value >
                  0) {
            Get.find<PersonalFilePageController>(tag: item.id)
                .followerCount
                .value--;
          }
        }
      },
    );
  }

  void addFollow() async {
    bool result = await item.addFollow();
    if (!result) {
      isFollowed(false);
    }
  }

  void removeFollow() async {
    bool result = await item.removeFollow();
    if (!result) {
      isFollowed(true);
    }
  }
}
