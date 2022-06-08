import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/services/collectionService.dart';

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

  @override
  void onInit() {
    fetchPickAndBookmark();
    super.onInit();
  }

  void fetchPickAndBookmark() async {
    isLoading(true);
    isError(false);
    try {
      pickAndBookmarkList.addAll(await service.fetchPickAndBookmark());
      for (var item in pickAndBookmarkList) {
        if (item.pickKinds!.contains(PickKind.read)) {
          pickedList.add(item);
        } else if (item.pickKinds!.contains(PickKind.bookmark)) {
          bookmarkList.add(item);
        }
      }
    } catch (e) {
      print('FetchPickAndBookmarkError: $e');
      isError.value = true;
      error = determineException(e);
    }
    isLoading(false);
  }
}
