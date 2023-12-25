import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionPick.dart';
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
  final collectionPicks = <CollectionPick>[].obs;

  final collectionDescription = ''.obs;
  final expandDescription = false.obs;

  final collectionFormat = CollectionFormat.folder.obs;

  @override
  void onInit() {
    collectionFormat.value = collection.format;
    super.onInit();
  }

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

  Future<void> fetchCollectionData({bool useCache = true}) async {
    try {
      await collectionPageRepos
          .fetchCollectionData(collection.id, useCache: useCache)
          .then((value) {
        //if collection deleted, replace to deleted page
        if (value['status'] == CollectionStatus.delete) {
          Get.off(() => const CollectionDeletedPage());
        } else {
          allComments.assignAll(value['allComments']);
          popularComments.assignAll(value['popularComments']);
          collectionPicks.assignAll(value['collectionPicks']);
          collection.collectionPicks = value['collectionPicks'];
          collectionDescription(value['description']);
          collectionFormat(value['format']);
        }
      });
      //update pick id list to ensure pick state is correct
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
      result = await collectionRepos.deleteCollection(
          collection.id, collection.ogImageId);
    } catch (e) {
      print('Delete collection failed: $e');
      result = false;
    }

    if (!result) {
      Fluttertoast.showToast(
        msg: "deleteFailedToast".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      // if current member's collection tab is exists, refetch to update after deleted
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList(useCache: false);
      }
      Get.back();
      Fluttertoast.showToast(
        msg: "deleteSuccessToast".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      //send pub/sub to delete related notifies
      Get.find<PubsubService>().removeCollection(
        memberId: Get.find<UserService>().currentUser.memberId,
        collectionId: collection.id,
      );
    }
  }
}
