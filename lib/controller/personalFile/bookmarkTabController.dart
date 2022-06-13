import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/services/personalFileService.dart';

class BookmarkTabController extends GetxController {
  final PersonalFileRepos personalFileRepos;
  BookmarkTabController(this.personalFileRepos);

  final bookmarkList = <Pick>[].obs;
  bool isLoading = true;
  bool isError = false;
  dynamic error;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;

  @override
  void onInit() {
    fetchBookmark();
    ever<List<Pick>>(bookmarkList, (callback) {
      if (Get.isRegistered<PersonalFilePageController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<PersonalFilePageController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .bookmarkCount
            .value = callback.length;
      }
    });
    super.onInit();
  }

  void fetchBookmark() async {
    isLoading = true;
    isError = false;
    isLoadingMore.value = false;
    isNoMore.value = false;
    update();
    try {
      await personalFileRepos
          .fetchBookmark()
          .then((value) => bookmarkList.assignAll(value));
      await Get.find<PickAndBookmarkService>().fetchPickIds();

      if (bookmarkList.length < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch bookmarkList error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void fetchMoreBookmark() async {
    isLoadingMore.value = true;
    try {
      List<Pick> newBookmarkList = await personalFileRepos.fetchBookmark(
        pickFilterTime: bookmarkList.last.pickedDate,
      );
      if (newBookmarkList.length < 10) {
        isNoMore.value = true;
      }
      await Get.find<PickAndBookmarkService>().fetchPickIds();
      bookmarkList.addAll(newBookmarkList);
    } catch (e) {
      print('Fetch more bookmarkList error: $e');
      Fluttertoast.showToast(
        msg: "載入更多失敗",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isLoadingMore.value = false;
  }
}
