import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/community/latestCommentBlockController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/communityService.dart';

class CommunityPageController extends GetxController {
  final CommunityRepos repository;
  CommunityPageController(this.repository);

  final followingPickedNews = <NewsListItem>[].obs;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;

  bool isInitialized = false;
  bool isError = false;
  dynamic error;
  final ScrollController scrollController = ScrollController();

  void initPage() async {
    isInitialized = false;
    isError = false;
    update();
    await Future.wait([
      fetchFollowingPickedNews().then((value) => isError = !value),
      Get.find<LatestCommentBlockController>().fetchLatestCommentNews(),
      Get.find<RecommendMemberBlockController>().fetchRecommendMembers(),
    ]);
    isInitialized = true;
    update();
  }

  Future<bool> fetchFollowingPickedNews() async {
    try {
      followingPickedNews
          .assignAll(await repository.fetchFollowingPickedNews());
      return true;
    } catch (e) {
      print('Fetch following picked news error: $e');
      error = determineException(e);
      return false;
    }
  }

  void scrollToTopAndRefresh() async {
    if (isInitialized) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(microseconds: 100));
        return !scrollController.hasClients;
      });
      await Future.wait([
        scrollController.animateTo(0,
            duration: const Duration(seconds: 2), curve: Curves.fastOutSlowIn),
        updateCommunityPage()
      ]);
    }
  }

  Future<void> updateCommunityPage() async {
    await Future.wait([
      fetchFollowingPickedNews(),
      Get.find<LatestCommentBlockController>().fetchLatestCommentNews(),
      Get.find<RecommendMemberBlockController>().fetchRecommendMembers(),
    ]);
  }

  void fetchMoreFollowingPickedNews() async {
    List<String> fetchedStoryIds = List<String>.from(followingPickedNews.map(
      (e) => e.id,
    ));
    try {
      isLoadingMore.value = true;
      List<NewsListItem> newPickedNewsList =
          await repository.fetchMoreFollowingPickedNews(fetchedStoryIds);
      followingPickedNews.addAll(newPickedNewsList);
      if (newPickedNewsList.isEmpty) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch more following picked news error: $e');
      Fluttertoast.showToast(
        msg: "載入更多失敗",
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
