import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/latestService.dart';

class LatestPageController extends GetxController {
  final LatestRepos repository;
  LatestPageController(this.repository);

  final List<NewsListItem> _allLatestNews = [];
  final showLatestNews = <NewsListItem>[].obs;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;
  final showLength = 20.obs;

  late bool showPaywall;
  late bool showFullScreenAd;

  bool isInitialized = false;
  bool isError = false;
  dynamic error;

  final prefs = Get.find<SharedPreferencesService>().prefs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    showPaywall = prefs.getBool('showPaywall') ?? true;
    showFullScreenAd = prefs.getBool('showFullScreenAd') ?? true;
    ever<bool>(Get.find<UserService>().isMember, (callback) {
      if (Get.find<RootPageController>().tabIndex.value == 1) {
        initPage();
      }
    });
    super.onInit();
  }

  void initPage() async {
    isInitialized = false;
    isError = false;
    update();
    await Future.wait([
      fetchLatestNews().then((value) => isError = !value),
      Get.find<RecommendPublisherBlockController>().fetchRecommendPublishers(),
    ]);
    isInitialized = true;
    update();
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
        updateLatestNewsPage()
      ]);
    }
  }

  Future<void> updateLatestNewsPage() async {
    await Future.wait([
      fetchLatestNews(),
      Get.find<RecommendPublisherBlockController>().fetchRecommendPublishers(),
    ]);
  }

  Future<bool> fetchLatestNews() async {
    try {
      _allLatestNews.assignAll(await repository.fetchLatestNews());
      showLatestNews.assignAll(_generateFilterList(_allLatestNews));
      if (_allLatestNews.length < 60) {
        isNoMore.value = true;
      } else {
        isNoMore.value = false;
      }

      if (showLatestNews.length < 20) {
        showLength.value = showLatestNews.length;
      } else {
        showLength.value = 20;
      }
      return true;
    } catch (e) {
      print('Fetch all latest news error: $e');
      error = determineException(e);
      return false;
    }
  }

  void loadMore() async {
    isLoadingMore.value = true;
    try {
      if (showLatestNews.length == showLength.value) {
        List<NewsListItem> moreLatestNews =
            await repository.fetchMoreLatestNews();
        if (moreLatestNews.length < 60) {
          isNoMore.value = true;
        } else {
          isNoMore.value = false;
        }
        showLatestNews.addAll(_generateFilterList(moreLatestNews));
        _allLatestNews.addAll(moreLatestNews);
      }
      int newLength = showLength.value + 20;
      if (newLength > showLatestNews.length) {
        newLength = showLatestNews.length;
      }
      showLength.value = newLength;
    } catch (e) {
      print('Fetch more latest news error: $e');
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

  void updateFilter() {
    showLatestNews.assignAll(_generateFilterList(_allLatestNews));
    if (showLength.value > showLatestNews.length) {
      showLength.value = showLatestNews.length;
    }
    prefs.setBool('showPaywall', showPaywall);
    prefs.setBool('showFullScreenAd', showFullScreenAd);
  }

  List<NewsListItem> _generateFilterList(List<NewsListItem> source) {
    List<NewsListItem> result = [];
    if (showFullScreenAd && showPaywall) {
      return source;
    }
    for (var item in source) {
      if (!showPaywall && !showFullScreenAd) {
        result.addIf(!item.payWall && !item.fullScreenAd, item);
      } else if (!showPaywall) {
        result.addIf(!item.payWall, item);
      } else if (!showFullScreenAd) {
        result.addIf(!item.fullScreenAd, item);
      }
    }
    return result;
  }
}
