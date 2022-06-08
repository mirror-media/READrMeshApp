import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/controller/pickableItemController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/services/collectionService.dart';
import 'package:readr/services/pickService.dart';

class CreateCollectionController extends GetxController {
  final CollectionRepos service;
  CreateCollectionController(this.service);

  //chooseStoryPage
  List<CollectionStory> pickAndBookmarkList = [];
  List<CollectionStory> pickedList = [];
  List<CollectionStory> bookmarkList = [];
  final selectedList = <CollectionStory>[].obs;
  var showPicked = true.obs;
  var showBookmark = true.obs;
  var isError = false.obs;
  var isLoading = true.obs;
  dynamic error;

  //inputTitlePage
  final collectionTitle = ''.obs;
  final collectionOgUrl = ''.obs;
  final TextEditingController titleTextController = TextEditingController();

  //create collection
  final isCreating = false.obs;

  @override
  void onInit() {
    fetchPickAndBookmark();
    super.onInit();
  }

  void fetchPickAndBookmark() async {
    isLoading(true);
    isError(false);
    try {
      var result = await service.fetchPickAndBookmark();
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

  void createCollection() async {
    isCreating.value = true;

    try {
      Collection newCollection = await service
          .createCollection(
            title: collectionTitle.value,
            ogImageUrl: collectionOgUrl.value,
            collectionStory: selectedList,
          )
          .timeout(
            const Duration(minutes: 1),
            onTimeout: () => throw Exception(),
          );

      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: newCollection.id,
          pickRepos: PickService(),
          objective: PickObjective.collection,
          controllerTag: newCollection.controllerTag,
        ),
        tag: newCollection.controllerTag,
        fenix: true,
      );
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      Get.offUntil<GetPageRoute>(
        GetPageRoute(
          routeName: '/CollectionPage',
          page: () => CollectionPage(
            newCollection,
            isNewCollection: true,
          ),
        ),
        (route) {
          return route.settings.name == '/PersonalFilePage' || route.isFirst;
        },
      );
    } catch (e) {
      print('Create collection error: $e');
      isCreating.value = false;
      Fluttertoast.showToast(
        msg: "建立失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isCreating.value = false;
  }
}
