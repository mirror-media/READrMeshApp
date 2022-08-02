import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/addToCollectionItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/collectionService.dart';

class AddToCollectionPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final NewsListItem news;
  AddToCollectionPageController(this.collectionRepos, this.news);

  List<AddToCollectionItem> alreadyPickCollections = [];
  List<AddToCollectionItem> notPickCollections = [];
  bool isLoading = true;
  dynamic error;

  @override
  void onInit() {
    fetchAllOwnCollections();
    super.onInit();
  }

  void fetchAllOwnCollections() async {
    isLoading = true;
    error = null;
    update();
    try {
      var result = await collectionRepos
          .fetchAndCheckOwnCollections(news.id)
          .timeout(1.minutes);
      alreadyPickCollections.assignAll(result['alreadyPickCollections'] ?? []);
      notPickCollections.assignAll(result['notPickCollections'] ?? []);
    } catch (e) {
      print('Fetch all own collections failed: $e');
      error = determineException(e);
    }
    isLoading = false;
    update();
  }

  void addStoryToCollection(AddToCollectionItem addToCollectionItem) async {
    try {
      await collectionRepos.addSingleStoryToCollection(
        collectionId: addToCollectionItem.id!,
        storyId: news.id,
        sortOrder: addToCollectionItem.collectionpicksCount! - 1,
      );
      _showResultToast(true);
    } catch (e) {
      print('Add new story to collection failed: $e');
      _showResultToast(false);
    }
  }

  void _showResultToast(bool isSuccess) {
    String message = isSuccess ? '成功加入集錦' : '加入集錦失敗';
    IconData iconData = isSuccess ? Icons.check_circle : Icons.error;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.0),
        color: const Color.fromRGBO(0, 9, 40, 0.66),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(
            width: 6.0,
          ),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
    showToastWidget(
      toast,
      context: Get.overlayContext,
      animation: StyledToastAnimation.slideFromTop,
      reverseAnimation: StyledToastAnimation.slideToTop,
      position: StyledToastPosition.top,
      startOffset: const Offset(0.0, -3.0),
      reverseEndOffset: const Offset(0.0, -3.0),
      duration: const Duration(seconds: 3),
      //Animation duration   animDuration * 2 <= duration
      animDuration: const Duration(milliseconds: 250),
      curve: Curves.linear,
      reverseCurve: Curves.linear,
    );
  }
}
