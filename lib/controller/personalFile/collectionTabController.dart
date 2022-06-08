import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/collectionService.dart';

class CollectionTabController extends GetxController {
  final CollectionRepos collectionRepos;
  final Member viewMember;
  CollectionTabController({
    required this.collectionRepos,
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

  Future<void> fetchCollecitionList() async {
    try {
      var result = await collectionRepos.fetchCollectionList(viewMember);
      collectionList.assignAll(result);
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
      var result = await collectionRepos.fetchMoreCollectionList(viewMember,
          List<String>.from(collectionList.map((element) => element.id)));
      collectionList.addAll(result);
      if (result.length < 20) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch more collection tab error: $e');
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
}
