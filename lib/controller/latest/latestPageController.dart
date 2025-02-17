import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/data/enum/page_status.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/routers/routers.dart';
import 'package:readr/services/latestService.dart';
import 'package:readr/services/user_cache_service.dart';

import '../../models/category.dart';

class LatestPageController extends GetxController
    with GetTickerProviderStateMixin {
  final LatestRepos repository;

  LatestPageController(this.repository);

  final UserCacheService userCacheService = Get.find();

  final List<NewsListItem> _allLatestNews = [];
  final showLatestNews = <NewsListItem>[].obs;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;
  final showLength = 20.obs;

  late bool showPaywall;
  late bool showFullScreenAd;
  final Rx<PageStatus> rxPageStatus = PageStatus.normal.obs;
  final RxBool isInitialized = false.obs;
  bool isError = false;
  dynamic error;

  final prefs = Get.find<SharedPreferencesService>().prefs;
  final ScrollController scrollController = ScrollController();
  final Rxn<TabController> rxnTabController = Rxn();
  final RxList<Widget> rxTabList = RxList();
  Worker? followCategoryListWorker;
  Category? selectCategory;

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
    fetchTabBar();
    followCategoryListWorker =
        ever(userCacheService.rxUserFollowCategoryList, (value) {
      if (value.isEmpty) return;
      fetchTabBar();
    });
  }

  void fetchTabBar() async {
    for (var item in userCacheService.rxUserFollowCategoryList.value) {
      print('fetchTabBar${item.title}');
    }
    rxnTabController.value = TabController(
        length: userCacheService.rxUserFollowCategoryList.value.length + 1,
        vsync: this);
    rxnTabController.value?.removeListener(tabBarClickEvent);
    rxnTabController.value?.addListener(tabBarClickEvent);
    selectCategory = userCacheService.rxUserFollowCategoryList[0];
    rxTabList.value = userCacheService.rxUserFollowCategoryList
        .map((category) => Tab(
              height: 36,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      category.title!,
                      style: const TextStyle(fontSize: 14), // 文字大小
                    ),
                  ),
                ),
              ),
            ))
        .toList();
    rxTabList.add(Tab(
      height: 36,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
                child: Icon(
              Icons.add,
              size: 15,
            )),
            SizedBox(
              width: 5,
            ),
            Text(
              '編輯',
              style: TextStyle(fontSize: 14), // 文字大小
            ),
          ],
        ),
      ),
    ));
    rxTabList.refresh();
  }

  void tabBarClickEvent() async {
    if (rxnTabController.value?.indexIsChanging == true) {
      if (rxnTabController.value?.index == rxTabList.length - 1) {
        await Get.toNamed(Routes.categoryEditPage);
        rxnTabController.value?.animateTo(0);
        selectCategory = userCacheService.rxUserFollowCategoryList[0];
        return;
      }
      selectCategory = userCacheService
          .rxUserFollowCategoryList[rxnTabController.value?.index ?? 0];
      fetchLatestNews();
    }
  }

  void initPage() async {
    isInitialized.value = false;
    isError = false;
    update();
    await Future.wait([
      fetchLatestNews().then((value) => isError = !value),
      Get.find<RecommendPublisherBlockController>().fetchRecommendPublishers(),
    ]);
    await Get.find<PickAndBookmarkService>().fetchPickIds();
    isInitialized.value = true;
    update();
  }

  void scrollToTopAndRefresh() async {
    if (isInitialized.value) {
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
    await Get.find<PickAndBookmarkService>().fetchPickIds();
  }

  Future<bool> fetchLatestNews() async {
    try {
      rxPageStatus.value = PageStatus.loading;
      await repository
          .fetchLatestNews(categoryId: selectCategory?.id ?? '0')
          .then((value) => _allLatestNews.assignAll(value));
      rxPageStatus.value = PageStatus.normal;
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
        List<NewsListItem> moreLatestNews = await repository
            .fetchMoreLatestNews(categoryId: selectCategory?.id ?? '0');
        await Get.find<PickAndBookmarkService>().fetchPickIds();
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
        msg: "loadMoreFailedToast".tr,
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

  @override
  void onClose() {
    followCategoryListWorker?.dispose();
  }
}

class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
