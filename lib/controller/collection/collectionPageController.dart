import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/collectionPageService.dart';
import 'package:readr/services/collectionService.dart';

class CollectionPageController extends GetxController {
  final Collection collection;
  final CollectionPageRepos collectionPageRepos;
  final CollectionRepos collectionRepos;
  final bool isNewCollection;
  CollectionPageController({
    required this.collection,
    required this.collectionPageRepos,
    required this.collectionRepos,
    this.isNewCollection = false,
  });

  bool isLoading = true;
  bool isError = false;
  dynamic error;

  final List<Comment> allComments = [];
  final List<Comment> popularComments = [];
  final collectionPicks = <CollectionStory>[].obs;

  @override
  void onReady() {
    if (!isNewCollection) {
      fetchCollectionData();
    } else {
      for (var item in collection.collectionPicks!) {
        if (item.news != null) {
          collectionPicks.add(item);
        }
      }

      isLoading = false;
      isError = false;
      update();
    }
    super.onReady();
  }

  Future<void> fetchCollectionData() async {
    try {
      await collectionPageRepos
          .fetchCollectionData(collection.id)
          .then((value) {
        allComments.assignAll(value['allComments']);
        popularComments.assignAll(value['popularComments']);
        collectionPicks.assignAll(value['collectionPicks']);
        collection.collectionPicks = value['collectionPicks'];
      });
      await Get.find<PickAndBookmarkService>().fetchPickIds();
    } catch (e) {
      print('Fetch collection data failed: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void deleteCollection() async {
    bool result;
    try {
      result = await collectionRepos.deleteCollection(collection.id);
    } catch (e) {
      print('Delete collection failed: $e');
      result = false;
    }

    if (!result) {
      Fluttertoast.showToast(
        msg: "刪除失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      Get.back();
      Fluttertoast.showToast(
        msg: "刪除成功",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
