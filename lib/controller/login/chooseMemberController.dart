import 'package:get/get.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/recommendService.dart';

class ChooseMemberController extends GetxController {
  final RecommendRepos recommendRepos;
  ChooseMemberController(this.recommendRepos);

  final List<Member> recommendedMembers = [];
  bool isLoading = true;
  bool isError = false;
  dynamic error;

  @override
  void onInit() {
    fetchRecommendMember();
    super.onInit();
  }

  void fetchRecommendMember() async {
    isLoading = true;
    isError = false;
    update();
    try {
      recommendedMembers
          .assignAll(await recommendRepos.fetchRecommendedMembers());
      isLoading = false;
    } catch (e) {
      print('Fetch recommend members error: $e');
      error = determineException(e);
      isError = true;
    }
    update();
  }
}
