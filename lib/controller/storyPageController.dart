import 'package:get/get.dart';
import 'package:readr/controller/personalFile/bookmarkTabController.dart';
import 'package:readr/controller/personalFile/personalFilePageController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/helpers/paragraphFormat.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/models/story.dart';
import 'package:readr/pages/shared/pick/pickToast.dart';
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

  bool isLoading = true;
  bool isError = false;
  dynamic error;
  final isBookmarked = false.obs;
  final webviewLoading = true.obs;
  late NewsStoryItem newsStoryItem;
  late Story readrStory;
  late ParagraphFormat paragraphFormat;
  String? _bookmarkId;

  @override
  void onInit() {
    super.onInit();
    fetchNewsData();
    debounce<bool>(
      isBookmarked,
      (callback) async {
        await updateBookmark();
      },
      time: const Duration(milliseconds: 500),
    );
  }

  void fetchNewsData() async {
    isLoading = true;
    isError = false;
    bool isFullContent = newsListItem.fullContent;
    print('Fetch news data id=${newsListItem.id}');
    update();
    await Get.find<UserService>().fetchUserData();
    try {
      newsStoryItem = await newsStoryRepos.fetchNewsData(newsListItem.id);

      //if publisher is readr and not project, fetch story from readr CMS
      if (newsListItem.source.id ==
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

      if (newsStoryItem.bookmarkId != null) {
        isBookmarked(true);
        _bookmarkId = newsStoryItem.bookmarkId;
      }
    } catch (e) {
      error = determineException(e);
      print('StoryPageError: ${error.message}');
      isError = true;
    }
    isLoading = false;
    update();
  }

  void updateNewsData(NewsListItem newNewsListItem) async {
    newsListItem = newNewsListItem;
    bool isFullContent = newsListItem.fullContent;
    await Get.find<UserService>().fetchUserData();
    try {
      newsStoryItem = await newsStoryRepos.fetchNewsData(newsListItem.id);

      //if publisher is readr and not project, fetch story from readr CMS
      if (newsListItem.source.id ==
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

      if (newsStoryItem.bookmarkId != null) {
        isBookmarked(true);
        _bookmarkId = newsStoryItem.bookmarkId;
      }
    } catch (e) {
      print('UpdateStoryPageError: ${error.message}');
    }
    update();
  }

  Future<void> updateBookmark() async {
    if (isBookmarked.isTrue && _bookmarkId == null) {
      _bookmarkId = await pickRepos.createPick(
        targetId: newsStoryItem.id,
        objective: PickObjective.story,
        state: PickState.private,
        kind: PickKind.bookmark,
      );
      PickToast.showBookmarkToast(_bookmarkId != null, true);
      if (_bookmarkId == null) {
        isBookmarked(false);
      } else {
        if (Get.isRegistered<BookmarkTabController>()) {
          Get.find<BookmarkTabController>().fetchBookmark();
        }

        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          final ownPersonalFileController =
              Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId);

          ownPersonalFileController.bookmarkCount.value++;
        }
      }
    } else if (isBookmarked.isFalse && _bookmarkId != null) {
      bool isDelete = await pickRepos.deletePick(_bookmarkId!);
      PickToast.showBookmarkToast(isDelete, false);
      if (!isDelete) {
        isBookmarked(true);
      } else {
        if (Get.isRegistered<BookmarkTabController>()) {
          Get.find<BookmarkTabController>()
              .bookmarkList
              .removeWhere((element) => element.id == _bookmarkId);
        }

        if (Get.isRegistered<PersonalFilePageController>(
            tag: Get.find<UserService>().currentUser.memberId)) {
          final ownPersonalFileController =
              Get.find<PersonalFilePageController>(
                  tag: Get.find<UserService>().currentUser.memberId);

          ownPersonalFileController.bookmarkCount.value > 0
              ? ownPersonalFileController.bookmarkCount.value--
              : ownPersonalFileController.bookmarkCount.value = 0;
        }
        _bookmarkId = null;
      }
    }
  }
}
