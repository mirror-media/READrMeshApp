import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/personalFileService.dart';

class CollectionTabController extends GetxController {
  final PersonalFileRepos personalFileRepos;
  final Member viewMember;
  CollectionTabController({
    required this.personalFileRepos,
    required this.viewMember,
  });

  bool isLoading = true;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;
  bool isError = false;
  final collectionList = <Collection>[].obs;
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
    await fetchCollecitionList();
  }

  Future<void> fetchCollecitionList({bool useCache = true}) async {
    try {
      await personalFileRepos
          .fetchCollectionList(viewMember, useCache: useCache)
          .then((value) => collectionList.assignAll(value));
      await Get.find<PickAndBookmarkService>().fetchPickIds();

      if (collectionList.length < 20) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch collection tab error: $e');
      error = determineException(e);
      isError = true;
    }
    isLoading = false;
    update();
  }

  void fetchMoreCollection() async {
    isLoadingMore.value = true;
    try {
      var result = await personalFileRepos.fetchMoreCollectionList(viewMember,
          List<String>.from(collectionList.map((element) => element.id)));
      await Get.find<PickAndBookmarkService>().fetchPickIds();
      collectionList.addAll(result);
      if (result.length < 20) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch more collection tab error: $e');
      Fluttertoast.showToast(
        msg: "loadFailedToast".tr,
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
