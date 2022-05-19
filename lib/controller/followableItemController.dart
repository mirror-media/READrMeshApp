import 'package:get/get.dart';
import 'package:readr/controller/login/choosePublisherController.dart';
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
          if (Get.isRegistered<ChoosePublisherController>()) {
            Get.find<ChoosePublisherController>().followedCount.value++;
          }
        } else {
          //update follow publisher count when onbroad
          if (Get.isRegistered<ChoosePublisherController>() &&
              Get.find<ChoosePublisherController>().followedCount.value > 0) {
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
    }
  }

  void removeFollow() async {
    bool result = await item.removeFollow();
    if (!result) {
      isFollowed(true);
    }
  }
}
