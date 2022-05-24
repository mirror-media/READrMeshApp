import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/services/communityService.dart';

class RecommendMemberBlockController extends RecommendItemController {
  final CommunityRepos repository;
  RecommendMemberBlockController(this.repository);

  final isLoading = true.obs;
  final recommendMembers = <FollowableItem>[].obs;

  Future<void> fetchRecommendMembers() async {
    try {
      List<Member> recommendMemberList =
          await repository.fetchRecommendMembers();
      recommendMembers.clear();
      for (var member in recommendMemberList) {
        recommendMembers.add(MemberFollowableItem(member));
      }
      isLoading.value = false;
    } catch (e) {
      print('Fetch recommend members error: $e');
    }
  }

  @override
  RxList<FollowableItem> get recommendItems => recommendMembers;

  @override
  FollowableItemType get itemType => FollowableItemType.member;
}
