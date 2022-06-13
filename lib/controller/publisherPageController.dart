import 'package:get/get.dart';
import 'package:readr/getxServices/pickAndBookmarkService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/publisherService.dart';

class PublisherPageController extends GetxController {
  final PublisherRepos publisherRepos;
  final Publisher publisher;
  PublisherPageController({
    required this.publisherRepos,
    required this.publisher,
  });

  final followerCount = 0.obs;
  final publisherNewsList = <NewsListItem>[].obs;
  final isLoadingMore = false.obs;
  final isNoMore = false.obs;

  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    fetchPublisherNews();
    super.onInit();
  }

  void fetchPublisherNews() async {
    isLoading = true;
    isError = false;
    update();
    try {
      var futureList = await Future.wait([
        publisherRepos.fetchPublisherNews(publisher.id, DateTime.now()),
        publisherRepos.fetchPublisherFollowerCount(publisher.id),
      ]);
      await Get.find<PickAndBookmarkService>().fetchPickIds();
      followerCount.value = futureList[1] as int;
      publisherNewsList.assignAll(futureList[0] as List<NewsListItem>);
      if (publisherNewsList.length < 20) {
        isNoMore.value = true;
      }
    } catch (e) {
      print('Fetch publisher news list error: $e');
      error = determineException(e);
    }
    isLoading = false;
    update();
  }

  void fetchMorePublisherNews() async {
    isLoadingMore.value = true;
    try {
      await Future.wait([
        publisherRepos
            .fetchPublisherNews(
                publisher.id, publisherNewsList.last.publishedDate)
            .then((value) {
          publisherNewsList.addAll(value);
          if (value.length < 20) {
            isNoMore.value = true;
          }
        }),
        publisherRepos
            .fetchPublisherFollowerCount(publisher.id)
            .then((value) => followerCount.value = value),
      ]);
      await Get.find<PickAndBookmarkService>().fetchPickIds();
    } catch (e) {
      print('Fetch more publisher news list error: $e');
    }
    isLoadingMore.value = false;
  }
}
