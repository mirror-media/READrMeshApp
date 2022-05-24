import 'package:get/get.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/services/communityService.dart';

class LatestCommentBlockController extends GetxController {
  final CommunityRepos repository;
  LatestCommentBlockController(this.repository);

  final isLoading = true.obs;
  final latestCommentsNewsList = <NewsListItem>[].obs;

  Future<void> fetchLatestCommentNews() async {
    try {
      latestCommentsNewsList
          .assignAll(await repository.fetchLatestCommentNews());
      isLoading.value = false;
    } catch (e) {
      print('Fetch latest comment news error: $e');
    }
  }
}
