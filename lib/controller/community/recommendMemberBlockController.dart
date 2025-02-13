import 'package:get/get.dart';
import 'package:readr/controller/recommendItemController.dart';
import 'package:readr/models/followableItem.dart';

class RecommendMemberBlockController extends RecommendItemController {
  final isLoading = true.obs;
  final recommendMembers = <FollowableItem>[].obs;

  RecommendMemberBlockController();

  @override
  RxList<FollowableItem> get recommendItems => recommendMembers;

  @override
  FollowableItemType get itemType => FollowableItemType.member;

  void updateRecommendMembers() {
    recommendMembers.refresh();
  }
}
