import 'package:get/get.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/recommendService.dart';

class ChoosePublisherController extends GetxController {
  final RecommendRepos repository;
  ChoosePublisherController(this.repository);

  final followedCount = 0.obs;
  late final List<Publisher> publishers;
  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    super.onInit();
    fetchAllPublishers();
  }

  Future<void> fetchAllPublishers() async {
    try {
      publishers = await repository.fetchAllPublishers();
      await Get.find<UserService>().fetchUserData();
      isLoading = false;
      isError = false;
    } catch (e) {
      print('Fetch all publisher error: $e');
      error = determineException(e);
      isError = true;
    }
    update();
  }
}
