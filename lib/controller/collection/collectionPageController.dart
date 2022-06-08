import 'package:get/get.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/collectionService.dart';

class CollectionPageController extends GetxController {
  final Collection collection;
  final CollectionRepos collectionRepos;
  CollectionPageController({
    required this.collection,
    required this.collectionRepos,
  });

  final isLoading = true.obs;
  final isError = false.obs;
  dynamic error;

  String inputText = '';
  final List<Comment> allComments = [];
  final List<Comment> popularComments = [];
  final collectionPicks = <CollectionStory>[].obs;

  @override
  void onInit() {
    if (collection.collectionPicks == null) {
      fetchCollectionPicks();
    } else {
      for (var item in collection.collectionPicks!) {
        if (item.news != null) {
          collectionPicks.add(item);
        }
      }

      isLoading(false);
      isError.value = false;
    }
    super.onInit();
  }

  void fetchCollectionPicks() {}
}
