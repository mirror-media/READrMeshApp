import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collectionPick.dart';
import 'package:readr/services/collectionService.dart';
import 'package:readr/services/searchService.dart';

class ChooseStoryPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final SearchRepos searchRepos;
  final List<String>? pickedStoryIds;
  ChooseStoryPageController(
    this.collectionRepos,
    this.searchRepos, {
    this.pickedStoryIds,
  });

  final pickAndBookmarkList = <CollectionPick>[].obs;
  final pickedList = <CollectionPick>[].obs;
  final bookmarkList = <CollectionPick>[].obs;
  final otherNewsList = <CollectionPick>[].obs;
  final selectedList = <CollectionPick>[].obs;
  final showPicked = true.obs;
  final showBookmark = true.obs;
  final isError = false.obs;
  final isLoading = true.obs;
  dynamic error;
  final isLoadingMore = false.obs;
  final noMorePick = false.obs;
  final noMoreBookmark = false.obs;
  //search
  final searchMode = false.obs;
  final keyWord = ''.obs;
  String searchWord = '';
  final MeiliSearchClient _client = MeiliSearchClient(
    Get.find<EnvironmentService>().config.searchSeverUrl,
    Get.find<EnvironmentService>().config.meiliMasterKey,
  );
  late final MeiliSearchIndex _index;
  final noMoreResults = false.obs;

  @override
  void onInit() {
    _index = _client.index('mesh');
    fetchPickAndBookmark();
    ever<bool>(searchMode, (callback) {
      if (!callback) {
        fetchPickAndBookmark();
        showPicked.value = true;
        showBookmark.value = true;
      }
      keyWord.value = '';
    });
    debounce<String>(
      keyWord,
      (callback) {
        if (showPicked.isTrue || showBookmark.isTrue) {
          fetchPickAndBookmark(keyWord: callback);
        } else {
          searchAllNews();
        }
        searchWord = callback;
      },
      time: 1.seconds,
    );
    super.onInit();
  }

  void fetchPickAndBookmark({String? keyWord}) async {
    isLoading(true);
    isError(false);
    noMorePick.value = false;
    noMoreBookmark.value = false;
    try {
      var result = await collectionRepos.fetchPickAndBookmark(
        keyWord: keyWord,
        fetchedPickStoryIds: pickedStoryIds,
        fetchedBookmarkStoryIds: pickedStoryIds,
      );
      pickAndBookmarkList.assignAll(result['pickAndBookmarkList']!);
      pickedList.assignAll(result['pickList']!);
      bookmarkList.assignAll(result['bookmarkList']!);

      if (pickedList.length < 50) {
        noMorePick.value = true;
      }

      if (bookmarkList.length < 50) {
        noMoreBookmark.value = true;
      }
    } catch (e) {
      print('FetchPickAndBookmarkError: $e');
      isError.value = true;
      error = determineException(e);
    }
    isLoading(false);
  }

  void loadMorePickAndBookmark({String? keyWord}) async {
    isLoadingMore.value = true;
    try {
      List<String> pickIdList =
          List<String>.from(pickedList.map((element) => element.pickNewsId));
      List<String> bookmarkIdList =
          List<String>.from(bookmarkList.map((element) => element.pickNewsId));
      var result = await collectionRepos.fetchPickAndBookmark(
        fetchedPickStoryIds: pickIdList,
        fetchedBookmarkStoryIds: bookmarkIdList,
        keyWord: keyWord,
      );
      pickAndBookmarkList.addAll(result['pickAndBookmarkList']!);
      pickedList.addAll(result['pickList']!);
      bookmarkList.addAll(result['bookmarkList']!);

      if (result['pickList']!.length < 50) {
        noMorePick.value = true;
      }

      if (result['bookmarkList']!.length < 50) {
        noMoreBookmark.value = true;
      }
    } catch (e) {
      print('FetchMorePickAndBookmarkError: $e');
      Fluttertoast.showToast(
        msg: "載入失敗 請稍後再試",
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

  void searchAllNews() async {
    isLoading(true);
    isError(false);
    noMoreResults.value = false;
    try {
      _index
          .search(
        keyWord.value,
        attributesToRetrieve: ['id', 'type'],
        filter: ['type = story'],
        sort: ['lastUpdated:desc'],
        limit: 50,
      )
          .then((value) async {
        if (value.hits?.isNotEmpty ?? false) {
          List<int> newsIdList =
              List<int>.from((value.hits!).map((e) => e['id']));
          await searchRepos.fetchNewsByIdList(newsIdList).then((value) =>
              otherNewsList.assignAll(List<CollectionPick>.from(
                  (value).map((e) => CollectionPick.fromNewsListItem(e)))));
        }
      });

      if (otherNewsList.length < 50) {
        noMoreResults.value = true;
      }
    } catch (e) {
      print('SearchAllNewsError: $e');
      isError.value = true;
      error = determineException(e);
    }
    isLoading(false);
  }

  void searchAllNewsLoadMore() async {
    isLoadingMore.value = true;
    try {
      _index
          .search(
        keyWord.value,
        attributesToRetrieve: ['id', 'type'],
        filter: ['type = story'],
        sort: ['lastUpdated:desc'],
        offset: otherNewsList.length,
        limit: 50,
      )
          .then((value) async {
        if (value.hits?.isNotEmpty ?? false) {
          List<int> newsIdList =
              List<int>.from((value.hits!).map((e) => e['id']));
          await searchRepos.fetchNewsByIdList(newsIdList).then((value) =>
              otherNewsList.addAll(List<CollectionPick>.from(
                  (value).map((e) => CollectionPick.fromNewsListItem(e)))));
          if (value.hits!.length < 50) {
            noMoreResults.value = true;
          }
        }
      });
    } catch (e) {
      print('SearchAllNewsLoadMoreError: $e');
      Fluttertoast.showToast(
        msg: "載入失敗 請稍後再試",
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
