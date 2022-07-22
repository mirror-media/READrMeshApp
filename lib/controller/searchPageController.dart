import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/searchService.dart';

class SearchPageController extends GetxController {
  final MeiliSearchClient _client = MeiliSearchClient(
    Get.find<EnvironmentService>().config.searchSeverUrl,
    Get.find<EnvironmentService>().config.meiliMasterKey,
  );
  late final MeiliSearchIndex _index;
  final TextEditingController textController = TextEditingController();

  String keyWord = '';
  final searchHistoryList = <String>[].obs;
  final newsResultList = <NewsListItem>[].obs;
  final collectionResultList = <Collection>[].obs;

  final isLoading = false.obs;
  final isLoadingMoreNews = false.obs;
  bool isLoadingMoreCollection = false;

  final noMoreNews = false.obs;
  bool noMoreCollection = false;
  bool noResult = false;

  final SearchRepos repos;
  SearchPageController(this.repos);

  @override
  void onInit() {
    _index = _client.index('mesh');
    textController.addListener(() {
      keyWord = textController.text;
    });

    searchHistoryList.assignAll(Get.find<SharedPreferencesService>()
            .prefs
            .getStringList('searchHistory') ??
        []);

    super.onInit();
  }

  @override
  void onClose() {
    textController.dispose();
    Get.find<SharedPreferencesService>()
        .prefs
        .setStringList('searchHistory', searchHistoryList);
    super.onClose();
  }

  void search(String keyWord) async {
    isLoading(true);
    noMoreNews.value = false;
    noMoreCollection = false;
    isLoadingMoreNews.value = false;
    isLoadingMoreCollection = false;
    if (!searchHistoryList.contains(keyWord)) {
      searchHistoryList.insert(0, keyWord);
    }
    newsResultList.clear();
    collectionResultList.clear();
    update();
    try {
      var result = await _index.search(
        keyWord,
        attributesToRetrieve: ['id', 'type'],
      );

      if (result.hits?.isNotEmpty ?? false) {
        List<int> newsIdList = [];
        List<int> collectionIdList = [];
        for (var item in result.hits!) {
          newsIdList.addIf(item['type'] == 'story', item['id']);
          collectionIdList.addIf(item['type'] == 'collection', item['id']);
        }
        await Future.wait([
          repos
              .fetchNewsByIdList(newsIdList)
              .then((value) => newsResultList.assignAll(value)),
          repos
              .fetchCollectionsByIdList(collectionIdList)
              .then((value) => collectionResultList.assignAll(value)),
        ]);

        if (result.hits!.length < 20) {
          noMoreNews.value = true;
          noMoreCollection = true;
        }

        if (newsResultList.isEmpty && collectionResultList.isEmpty) {
          noResult = true;
        }
        noResult = false;
      } else {
        noResult = true;
      }
    } catch (e) {
      print('Search failed: $e');
      Fluttertoast.showToast(
        msg: '發生錯誤 請稍後再試',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }
    isLoading(false);
    update();
  }

  void loadMoreNews() async {
    isLoadingMoreNews.value = true;

    try {
      var result = await _index.search(
        keyWord,
        attributesToRetrieve: ['id', 'type'],
        offset: newsResultList.length,
      );

      if (result.hits?.isNotEmpty ?? false) {
        List<int> newsIdList = [];

        for (var item in result.hits!) {
          newsIdList.addIf(item['type'] == 'story', item['id']);
        }
        await repos.fetchNewsByIdList(newsIdList).then((value) {
          newsResultList.addAll(value);
        });

        if (result.hits!.length < 20) {
          noMoreNews.value = true;
        }
      }
    } catch (e) {
      print('Fetch more search news error failed: $e');
      Fluttertoast.showToast(
        msg: '載入更多發生錯誤 請稍後再試',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }
    isLoadingMoreNews.value = false;
  }

  void loadMoreCollection() async {
    isLoadingMoreCollection = true;
    try {
      var result = await _index.search(
        keyWord,
        attributesToRetrieve: ['id', 'type'],
        offset: collectionResultList.length,
      );

      if (result.hits?.isNotEmpty ?? false) {
        List<int> collectionIdList = [];

        for (var item in result.hits!) {
          collectionIdList.addIf(item['type'] == 'collection', item['id']);
        }
        await repos.fetchCollectionsByIdList(collectionIdList).then((value) {
          collectionResultList.addAll(value);
        });

        if (result.hits!.length < 20) {
          noMoreCollection = true;
        }
      }
    } catch (e) {
      print('Fetch more search collection error failed: $e');
      Fluttertoast.showToast(
        msg: '載入更多發生錯誤 請稍後再試',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
    }

    isLoadingMoreCollection = false;
  }
}
