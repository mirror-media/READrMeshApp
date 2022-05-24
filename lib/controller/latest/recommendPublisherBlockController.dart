import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/latestService.dart';

class RecommendPublisherBlockController extends RecommendItemController {
  final LatestRepos repository;
  RecommendPublisherBlockController(this.repository);

  final isLoading = true.obs;
  final recommendPublishers = <FollowableItem>[].obs;

  Future<void> fetchRecommendPublishers() async {
    try {
      List<Publisher> recommendPublisherList =
          await repository.fetchRecommendPublishers();
      recommendPublishers.clear();
      for (var publisher in recommendPublisherList) {
        recommendPublishers.add(PublisherFollowableItem(publisher));
      }
      isLoading.value = false;
    } catch (e) {
      print('Fetch recommend publishers error: $e');
    }
  }

  @override
  RxList<FollowableItem> get recommendItems => recommendPublishers;

  @override
  FollowableItemType get itemType => FollowableItemType.publisher;
}
