import 'package:get/get.dart';
import 'package:readr/controller/notify/notifyItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/announcement.dart';
import 'package:readr/models/notify.dart';
import 'package:readr/models/notifyPageItem.dart';
import 'package:readr/services/notifyService.dart';

class NotifyPageController extends GetxController {
  final NotifyRepos notifyRepos;
  NotifyPageController(this.notifyRepos);

  final announcementList = <Announcement>[].obs;
  final unReadNotifyList = <NotifyPageItem>[].obs;
  final readNotifyList = <NotifyPageItem>[].obs;

  @override
  void onInit() {
    fetchNotifies();
    super.onInit();
  }

  void readAll() {
    for (var notifyPageItem in unReadNotifyList) {
      Get.find<NotifyItemController>(tag: notifyPageItem.id).alreadyRead.value =
          true;
    }
    readNotifyList.insertAll(0, unReadNotifyList);
    unReadNotifyList.clear();
  }

  Future<void> fetchNotifies() async {
    List<Notify> localNotifies = [];
    List<Notify> newNotifies = await notifyRepos
        .fetchNotifies(
          alreadyFetchNotifyIds:
              List<String>.from(localNotifies.map((e) => e.id)),
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => []);
    newNotifies.addAll(localNotifies);
    List<NotifyPageItem> allPageItems =
        _generatePageItemFromNotifies(newNotifies);
    allPageItems.sort((a, b) => b.actionTime.compareTo(a.actionTime));
    allPageItems = await notifyRepos.fetchNotifyRelatedItems(allPageItems);
    unReadNotifyList.clear();
    readNotifyList.clear();
    for (var pageItem in allPageItems) {
      if (pageItem.isRead) {
        readNotifyList.add(pageItem);
      } else {
        unReadNotifyList.add(pageItem);
      }
    }
  }

  List<NotifyPageItem> _generatePageItemFromNotifies(List<Notify> notifyList) {
    List<NotifyPageItem> pageItemList = [];
    for (var notify in notifyList) {
      int index = -1;
      if (notify.type == NotifyType.follow) {
        index = pageItemList
            .indexWhere((element) => element.type == NotifyType.follow);
      } else {
        index = pageItemList.indexWhere((element) =>
            element.type == notify.type && element.objectId == notify.objectId);
      }

      if (index == -1) {
        pageItemList.add(NotifyPageItem.fromNotify(notify));
      } else {
        pageItemList[index].relatedNotifies.add(notify);
        pageItemList[index].senderList.addIf(
            !pageItemList[index]
                .senderList
                .any((element) => element.memberId == notify.sender.memberId),
            notify.sender);
        pageItemList[index].isRead =
            pageItemList[index].isRead && notify.isRead;
        if (notify.actionTime.isAfter(pageItemList[index].actionTime)) {
          pageItemList[index].actionTime = notify.actionTime;
        }
      }
    }

    return pageItemList;
  }

  void readItem(String id) {
    int itemIndex = unReadNotifyList.indexWhere((element) => element.id == id);
    if (itemIndex != -1) {
      readNotifyList.add(unReadNotifyList[itemIndex]);
      readNotifyList.sort((a, b) => b.actionTime.compareTo(a.actionTime));
      unReadNotifyList.removeAt(itemIndex);
    }
  }
}
