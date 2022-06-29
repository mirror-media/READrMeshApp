import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/helpers/dataConstants.dart';
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
  final isLoadingMoreStoryPick = false.obs;
  final isLoadingMoreCollectionPick = false.obs;
  final noMoreStoryPick = false.obs;
  final noMoreCollectionPick = false.obs;
  bool isError = false;
  final storyPickList = <Pick>[].obs;
  final collecionPickList = <Pick>[].obs;
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
      await Future.wait([
        personalFileRepos
            .fetchStoryPicks(viewMember)
            .then((value) => storyPickList.assignAll(value)),
        personalFileRepos
            .fetchCollectionPicks(viewMember)
            .then((value) => collecionPickList.assignAll(value)),
        Get.find<PickAndBookmarkService>().fetchPickIds(),
      ]);

      if (storyPickList.length < 20) {
        noMoreStoryPick.value = true;
      } else {
        noMoreStoryPick.value = false;
      }

      if (collecionPickList.length < 20) {
        noMoreCollectionPick.value = true;
      } else {
        noMoreCollectionPick.value = false;
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
    isLoadingMoreStoryPick.value = true;
    try {
      await personalFileRepos
          .fetchStoryPicks(viewMember,
              pickFilterTime: storyPickList.last.pickedDate)
          .then((value) {
        storyPickList.addAll(value);
        if (value.length < 20) {
          noMoreStoryPick.value = true;
        }
      });
    } catch (e) {
      print('Fetch more story picks error: $e');
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
    isLoadingMoreStoryPick.value = false;
  }

  void fetchMoreCollectionPick() async {
    isLoadingMoreCollectionPick.value = true;
    try {
      await personalFileRepos
          .fetchCollectionPicks(viewMember,
              pickFilterTime: collecionPickList.last.pickedDate)
          .then((value) {
        collecionPickList.addAll(value);
        if (value.length < 20) {
          noMoreCollectionPick.value = true;
        }
      });
    } catch (e) {
      print('Fetch more collection picks error: $e');
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
    isLoadingMoreCollectionPick.value = false;
  }

  void deletePickComment(String commentId, String controllerTag) async {
    bool result =
        await Get.find<PubsubService>().removeComment(commentId: commentId);
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

  void unPick(PickObjective objective, String pickId) async {
    storyPickList.removeWhere((element) => element.id == pickId);
    collecionPickList.removeWhere((element) => element.id == pickId);
  }
}
