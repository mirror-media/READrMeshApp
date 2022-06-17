import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/story.dart';
import 'package:readr/services/newsStoryService.dart';
import 'package:readr/services/pickService.dart';
import 'package:readr/services/storyService.dart';

class StoryPageController extends GetxController {
  final NewsStoryRepos newsStoryRepos;
  final StoryRepos storyRepos;
  final PickRepos pickRepos;
  NewsListItem newsListItem;
  StoryPageController({
    required this.newsStoryRepos,
    required this.storyRepos,
    required this.pickRepos,
    required this.newsListItem,
  });

  final isLoading = true.obs;
  bool isError = false;
  dynamic error;
  late NewsStoryItem newsStoryItem;
  late Story readrStory;
  late ParagraphFormat paragraphFormat;

  @override
  void onInit() {
    super.onInit();
    fetchNewsData();
  }

  void fetchNewsData() async {
    isLoading.value = true;
    isError = false;
    bool isFullContent = newsListItem.fullContent;
    print('Fetch news data id=${newsListItem.id}');
    update();
    await Get.find<UserService>().fetchUserData();
    await Get.find<PickAndBookmarkService>().fetchPickIds();
    try {
      await Future.wait([
        Get.find<UserService>().fetchUserData(),
        Get.find<PickAndBookmarkService>().fetchPickIds(),
        newsStoryRepos
            .fetchNewsData(newsListItem.id)
            .then((value) => newsStoryItem = value),
      ]);

      //if publisher is readr and not project, fetch story from readr CMS
      if (newsListItem.source?.id ==
              Get.find<EnvironmentService>().config.readrPublisherId &&
          isFullContent) {
        if (newsStoryItem.content == null || newsStoryItem.content!.isEmpty) {
          error = determineException('No content error');
          isError = true;
        } else {
          readrStory =
              await storyRepos.fetchPublishedStoryById(newsStoryItem.content!);
          paragraphFormat = ParagraphFormat(readrStory.imageUrlList);
        }
      }
    } catch (e) {
      error = determineException(e);
      print('StoryPageError: ${error.message}');
      isError = true;
    }
    isLoading.value = false;
    update();
  }

  void updateNewsData(NewsListItem newNewsListItem) async {
    newsListItem = newNewsListItem;
    bool isFullContent = newsListItem.fullContent;
    await Get.find<UserService>().fetchUserData();
    try {
      newsStoryItem = await newsStoryRepos.fetchNewsData(newsListItem.id);

      //if publisher is readr and not project, fetch story from readr CMS
      if (newsListItem.source?.id ==
              Get.find<EnvironmentService>().config.readrPublisherId &&
          isFullContent) {
        if (newsStoryItem.content == null || newsStoryItem.content!.isEmpty) {
          error = determineException('No content error');
          isError = true;
        } else {
          readrStory =
              await storyRepos.fetchPublishedStoryById(newsStoryItem.content!);
          paragraphFormat = ParagraphFormat(readrStory.imageUrlList);
        }
      }
    } catch (e) {
      print('UpdateStoryPageError: ${error.message}');
    }
    update();
  }
}
