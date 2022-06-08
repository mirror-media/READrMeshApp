import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/services/collectionPageService.dart';
import 'package:readr/services/collectionService.dart';

class EditCollectionController extends GetxController {
  final CollectionRepos collectionRepos;
  final Collection collection;
  EditCollectionController({
    required this.collectionRepos,
    required this.collection,
  });

  //edit title and heroImage page
  late final RxString title;
  late final RxString heroImageUrl;
  late final TextEditingController titleTextController;

  //reorder page
  final List<CollectionStory> originalList = [];
  final newList = <CollectionStory>[].obs;

  //add story page
  List<CollectionStory> pickAndBookmarkList = [];
  List<CollectionStory> pickedList = [];
  List<CollectionStory> bookmarkList = [];
  final selectedList = <CollectionStory>[].obs;
  var showPicked = true.obs;
  var showBookmark = true.obs;
  var isError = false.obs;
  var isLoading = true.obs;
  dynamic error;

  final isUpdating = false.obs;

  @override
  void onInit() {
    title = collection.title.obs;
    heroImageUrl = collection.ogImageUrl.obs;
    titleTextController = TextEditingController(text: collection.title);
    originalList.assignAll(collection.collectionPicks!);
    newList.assignAll(originalList);
    super.onInit();
  }

  void updateTitleAndOg() async {
    isUpdating.value = true;

    try {
      Collection newCollection = await collectionRepos.updateTitleAndOg(
        collectionId: collection.id,
        heroImageId: collection.ogImageId,
        newTitle: title.value,
        newOgUrl: heroImageUrl.value,
      );

      Get.back();
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      Get.off(
        () => CollectionPage(
          newCollection,
        ),
        preventDuplicates: false,
        binding: BindingsBuilder(() {
          Get.lazyPut<CollectionPageController>(
            () => CollectionPageController(
              collection: newCollection,
              collectionPageRepos: CollectionPageService(),
              collectionRepos: CollectionService(),
            ),
            tag: newCollection.id,
          );
        }),
      );
    } catch (e) {
      print('Update collection title and og error: $e');
      _errorToast();
      isUpdating.value = false;
    }
  }

  void fetchPickAndBookmark() async {
    isLoading.value = true;
    isError.value = false;
    try {
      var result = await collectionRepos.fetchPickAndBookmark(
        fetchedStoryIds:
            List<String>.from(newList.map((element) => element.news!.id)),
      );
      pickAndBookmarkList.assignAll(result['pickAndBookmarkList']!);
      pickedList.assignAll(result['pickList']!);
      bookmarkList.assignAll(result['bookmarkList']!);
      selectedList.clear();
    } catch (e) {
      print('FetchPickAndBookmarkError: $e');
      isError.value = true;
      error = determineException(e);
    }
    isLoading(false);
  }

  void addNewItem() {
    selectedList
        .sort((a, b) => b.news!.publishedDate.compareTo(a.news!.publishedDate));
    newList.insertAll(0, selectedList);
  }

  void updateCollectionPicks() async {
    isUpdating.value = true;
    List<CollectionStory> originItemList = [];
    originItemList.assignAll(originalList);
    List<CollectionStory> addItemList = [];
    List<CollectionStory> moveItemList = [];
    List<CollectionStory> deleteItemList = [];

    for (int i = 0; i < newList.length; i++) {
      newList[i].sortOrder = i;
      int originListIndex = originItemList
          .indexWhere((element) => element.news!.id == newList[i].news!.id);
      if (originListIndex == -1) {
        addItemList.add(newList[i]);
      } else if (i != originListIndex) {
        moveItemList.add(newList[i]);
        originItemList.removeAt(originListIndex);
      } else {
        originItemList.removeAt(originListIndex);
      }
    }

    if (originItemList.isNotEmpty) {
      deleteItemList.assignAll(originItemList);
    }

    List<Future> futureList = [];
    futureList.addIf(
      addItemList.isNotEmpty,
      collectionRepos.createCollectionPicks(
        collection: collection,
        collectionStory: addItemList,
      ),
    );
    futureList.addIf(
      moveItemList.isNotEmpty,
      collectionRepos.updateCollectionPicksOrder(
        collectionId: collection.id,
        collectionStory: moveItemList,
      ),
    );
    futureList.addIf(
      deleteItemList.isNotEmpty,
      collectionRepos.removeCollectionPicks(
        collectionStory: deleteItemList,
      ),
    );

    try {
      await Future.wait(futureList);
      await Get.find<CollectionPageController>(tag: collection.id)
          .fetchCollectionData();
      Get.back();
    } catch (e) {
      print('Update collection picks error: $e');
      _errorToast();
      isUpdating.value = false;
    }
  }

  void _errorToast() {
    Fluttertoast.showToast(
      msg: "更新失敗 請稍後再試",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
