import 'package:get/get.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/readrListItem.dart';
import 'package:readr/services/tabStoryListService.dart';

class ReadrTabController extends GetxController {
  final TabStoryListRepos tabStoryListRepos;
  final String categorySlug;
  ReadrTabController({
    required this.tabStoryListRepos,
    required this.categorySlug,
  });

  final readrMixedList = <ReadrListItem>[].obs;
  final noMore = false.obs;
  final isLoadingMore = false.obs;
  dynamic error;
  bool isLoading = true;
  bool isError = false;
  int _storySkip = 0;
  int _projectSkip = 0;

  @override
  void onInit() {
    fetchStoryList();
    super.onInit();
  }

  void fetchStoryList() async {
    isLoading = true;
    isError = false;
    noMore.value = false;
    _storySkip = 0;
    _projectSkip = 0;
    update();
    try {
      Map<String, List<NewsListItem>> result = {
        'story': [],
        'project': [],
      };
      if (categorySlug == 'latest') {
        result = await tabStoryListRepos.fetchStoryList();
      } else {
        result =
            await tabStoryListRepos.fetchStoryListByCategorySlug(categorySlug);
      }
      await Get.find<PickAndBookmarkService>().fetchPickIds();
      readrMixedList.assignAll(_mixTwoList(
        storyList: result['story']!,
        projectList: result['project']!,
      ));
    } catch (e) {
      print('Fetch READr $categorySlug story list error: $e');
      isError = true;
      error = determineException(e);
    }
    isLoading = false;
    update();
  }

  void fetchMoreStory() async {
    isLoadingMore.value = true;
    try {
      Map<String, List<NewsListItem>> result = {
        'story': [],
        'project': [],
      };
      if (categorySlug == 'latest') {
        result = await tabStoryListRepos.fetchStoryList(
          storySkip: _storySkip,
          projectSkip: _projectSkip,
          storyFirst: 12,
        );
      } else {
        result = await tabStoryListRepos.fetchStoryListByCategorySlug(
          categorySlug,
          storySkip: _storySkip,
          projectSkip: _projectSkip,
          storyFirst: 12,
        );
      }
      await Get.find<PickAndBookmarkService>().fetchPickIds();

      if (result['story']!.isEmpty && result['project']!.isEmpty) {
        noMore.value = true;
      }
      _storySkip = _storySkip + result['story']!.length;
      _projectSkip = _projectSkip + result['project']!.length;

      readrMixedList.addAll(_mixTwoList(
        storyList: result['story']!,
        projectList: result['project']!,
        loadMore: true,
      ));
    } catch (e) {
      print('Fetch more READr $categorySlug story list error: $e');
      isLoadingMore.value = false;
    }
    isLoadingMore.value = false;
  }

  List<ReadrListItem> _mixTwoList({
    required List<NewsListItem> storyList,
    required List<NewsListItem> projectList,
    bool loadMore = false,
  }) {
    List<ReadrListItem> tempList = [];
    for (var item in storyList) {
      tempList.add(ReadrListItem(item, false));
    }
    if (tempList.isEmpty) {
      for (var item in projectList) {
        tempList.add(ReadrListItem(item, true));
      }
    } else {
      int pointer = loadMore ? 0 : 6;
      for (int i = 0; i < projectList.length; i++) {
        if (pointer < tempList.length) {
          tempList.insert(pointer, ReadrListItem(projectList[i], true));
          pointer = pointer + 7;
        } else {
          tempList.add(ReadrListItem(projectList[i], true));
        }
      }
    }
    return tempList;
  }
}
