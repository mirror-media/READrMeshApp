import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/pickIdItem.dart';
import 'package:readr/services/memberService.dart';

class PickAndBookmarkService extends GetxService {
  final List<PickIdItem> pickList = [];
  final List<PickIdItem> bookmarkList = [];
  final MemberService _memberService = MemberService();
  Future<PickAndBookmarkService> init() async {
    return this;
  }

  Duration get _timeout {
    if (Get.find<EnvironmentService>().flavor == BuildFlavor.development) {
      return const Duration(minutes: 3);
    }
    return const Duration(seconds: 5);
  }

  Future<void> fetchPickIds() async {
    if (Get.find<UserService>().isMember.isTrue) {
      try {
        List<PickIdItem> newPickIdList =
            await _memberService.fetchAllPicksAndBookmarks().timeout(_timeout);
        pickList.clear();
        bookmarkList.clear();
        for (var item in newPickIdList) {
          switch (item.kind) {
            case PickKind.bookmark:
              bookmarkList.add(item);
              break;
            case PickKind.collect:
              break;
            case PickKind.read:
              pickList.add(item);
              break;
          }
          _updatePickableItemController(item);
        }
      } catch (e) {
        print('Fetch pick ids failed: $e');
      }
    }
  }

  void _updatePickableItemController(PickIdItem item) {
    String tag = '';
    switch (item.objective) {
      case PickObjective.story:
        tag = 'News${item.targetId}';
        break;
      case PickObjective.comment:
        break;
      case PickObjective.collection:
        tag = 'Collection${item.targetId}';
        break;
    }
    switch (item.kind) {
      case PickKind.bookmark:
        if (Get.isRegistered<PickableItemController>(tag: tag) ||
            Get.isPrepared<PickableItemController>(tag: tag)) {
          Get.find<PickableItemController>(tag: tag).isBookmarked.value = true;
        }
        break;
      case PickKind.collect:
        break;
      case PickKind.read:
        if (Get.isRegistered<PickableItemController>(tag: tag) ||
            Get.isPrepared<PickableItemController>(tag: tag)) {
          Get.find<PickableItemController>(tag: tag).isPicked.value = true;
        }
        break;
    }
  }
}
