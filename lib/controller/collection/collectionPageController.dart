import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/services/collectionPageService.dart';

class CollectionPageController extends GetxController {
  final Collection collection;
  final CollectionPageRepos collectionPageRepos;
  CollectionPageController({
    required this.collection,
    required this.collectionPageRepos,
  });

  final isLoading = true.obs;
  final isError = false.obs;
  dynamic error;

  String inputText = '';
  final List<Comment> allComments = [];
  final List<Comment> popularComments = [];
  final collectionPicks = <CollectionStory>[].obs;
  late final Rx<Collection> collectionData;

  @override
  void onInit() {
    collectionData = collection.obs;
    if (collection.collectionPicks == null) {
      fetchCollectionData();
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

  void fetchCollectionData() async {
    try {
      var result = await collectionPageRepos.fetchCollectionData(collection.id);
      allComments.assignAll(result['allComments']);
      popularComments.assignAll(result['popularComments']);
      collectionPicks.assignAll(result['collectionPicks']);
      collection.collectionPicks = result['collectionPicks'];
    } catch (e) {
      print('Fetch collection data failed: $e');
      error = determineException(e);
      isError.value = true;
    }
    isLoading(false);
  }
}
