import 'package:get/get.dart';
import 'package:readr/services/community_service.dart';
import 'package:readr/pages/community/community_controller.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CommunityService());
    Get.lazyPut(() => CommunityController());
  }
}
