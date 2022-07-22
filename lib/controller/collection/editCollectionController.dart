import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/services/collectionService.dart';

class EditCollectionController extends GetxController {
  final CollectionRepos collectionRepos;
  final Collection collection;
  final bool isReorderPage;
  final String description;
  EditCollectionController({
    required this.collectionRepos,
    required this.collection,
    this.isReorderPage = false,
    this.description = '',
  });

  //edit title and heroImage page
  late final RxString title;
  late final RxString collectionOgUrlOrPath;
  late final TextEditingController titleTextController;

  //reorder page
  final List<CollectionStory> originalList = [];
  final newList = <CollectionStory>[].obs;
  bool isFirstTime = true;

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

  //editDescriptionPage
  final collectionDescription = ''.obs;

  final isUpdating = false.obs;

  @override
  void onInit() {
    title = Get.find<PickableItemController>(tag: collection.controllerTag)
        .collectionTitle
        .value!
        .obs;
    collectionOgUrlOrPath =
        Get.find<PickableItemController>(tag: collection.controllerTag)
            .collectionHeroImageUrl
            .value!
            .obs;
    titleTextController = TextEditingController(text: title.value);
    originalList.assignAll(collection.collectionPicks!);
    newList.assignAll(originalList);
    isFirstTime = Get.find<SharedPreferencesService>()
            .prefs
            .getBool('firstTimeEditCollection') ??
        true;
    collectionDescription.value = description;
    super.onInit();
  }

  @override
  void onReady() {
    if (isFirstTime && isReorderPage) {
      _showDeleteHint();
    }
    super.onReady();
  }

  void updateTitleAndOg() async {
    isUpdating.value = true;

    try {
      await collectionRepos
          .updateOgPhoto(
              photoId: collection.ogImageId,
              ogImageUrlOrPath: collectionOgUrlOrPath.value)
          .timeout(const Duration(minutes: 1));
      await collectionRepos
          .updateTitle(
            collectionId: collection.id,
            newTitle: title.value,
          )
          .timeout(const Duration(minutes: 1));

      Get.back();
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
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

  void _showDeleteHint() async {
    await showGeneralDialog(
      context: Get.overlayContext!,
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                collectionDeleteHintSvg,
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                '向左滑可以刪除文章',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.find<SharedPreferencesService>()
                      .prefs
                      .setBool('firstTimeEditCollection', false);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  primary: Colors.white,
                ),
                child: const Text(
                  '我知道了',
                  style: TextStyle(
                    fontSize: 16,
                    color: readrBlack87,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void updateDescription() async {
    isUpdating.value = true;

    try {
      await collectionRepos.updateDescription(
        collectionId: collection.id,
        description: collectionDescription.value,
      );

      Get.find<CollectionPageController>(tag: collection.id)
          .collectionDescription
          .value = collectionDescription.value;

      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }

      Get.back();
    } catch (e) {
      print('Update collection description error: $e');
      _errorToast();
      isUpdating.value = false;
    }
  }
}
