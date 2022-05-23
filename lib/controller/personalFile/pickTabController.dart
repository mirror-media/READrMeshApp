import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/services/commentService.dart';
import 'package:readr/services/personalFileService.dart';

class PickTabController extends GetxController {
  final PersonalFileRepos personalFileRepos;
  final CommentRepos commentRepos;
  final Member viewMember;
  PickTabController(this.personalFileRepos, this.commentRepos, this.viewMember);

  bool isLoading = true;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;
  bool isError = false;
  final storyPickList = <Pick>[].obs;
  dynamic error;

  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  void initPage() async {
    isLoading = true;
    isError = false;
    update();
    await fetchPickList();
  }

  Future<void> fetchPickList() async {
    try {
      var result = await personalFileRepos.fetchPickData(viewMember);
      storyPickList.assignAll(result['storyPickList']);
      if (storyPickList.length < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch Pick Tab Error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void fetchMoreStoryPick() async {
    isLoadingMore.value = true;
    try {
      var result = await personalFileRepos.fetchPickData(viewMember,
          pickFilterTime: storyPickList.last.pickedDate);
      storyPickList.addAll(result['storyPickList']);
      if (result['storyPickList'].length < 10) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch More Pick Tab Error: $e');
      Fluttertoast.showToast(
        msg: "載入失敗",
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

  void deletePickComment(String commentId, String controllerTag) async {
    bool result = await commentRepos.deleteComment(commentId);
    if (result) {
      int index = storyPickList
          .indexWhere((element) => element.pickComment?.id == commentId);
      if (index != -1) {
        storyPickList[index].pickComment = null;
        storyPickList.refresh();
        Get.find<PickableItemController>(tag: controllerTag)
            .commentCount
            .value--;
      }
    }
  }

  void unPick(String pickId) async {
    storyPickList.removeWhere((element) => element.id == pickId);
  }
}
