import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/collection/collectionDeletedPage.dart';
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

  final collectionDescription = ''.obs;
  final expandDescription = false.obs;

  @override
  void onReady() {
    if (!isNewCollection) {
      fetchCollectionData();
    } else {
      for (var item in collection.collectionPicks!) {
        collectionPicks.add(item);
      }

      isLoading = false;
      isError = false;
      update();
    }
    super.onReady();
  }

  Future<void> fetchCollectionData() async {
    try {
      await Get.find<UserService>().fetchUserData();
      await collectionPageRepos
          .fetchCollectionData(collection.id)
          .then((value) {
        if (value['status'] == CollectionStatus.delete) {
          Get.off(() => const CollectionDeletedPage());
        } else {
          allComments.assignAll(value['allComments']);
          popularComments.assignAll(value['popularComments']);
          collectionPicks.assignAll(value['collectionPicks']);
          collection.collectionPicks = value['collectionPicks'];
          collectionDescription(value['description']);
        }
      });
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
      result = await collectionRepos.deleteCollection(
          collection.id, collection.ogImageId);
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
      Get.find<PubsubService>().removeCollection(
        memberId: Get.find<UserService>().currentUser.memberId,
        collectionId: collection.id,
      );
    }
  }
}
