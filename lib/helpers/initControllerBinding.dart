import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/latestCommentBlockController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/services/communityService.dart';
import 'package:readr/services/latestService.dart';

class InitControllerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RootPageController(), permanent: true);
    Get.put(LatestCommentBlockController(CommunityService()), permanent: true);
    Get.put(RecommendMemberBlockController(CommunityService()),
        permanent: true);
    Get.put(CommunityPageController(CommunityService()), permanent: true);
    Get.put(RecommendPublisherBlockController(LatestService()),
        permanent: true);
    Get.put(LatestPageController(LatestService()), permanent: true);
  }
}
