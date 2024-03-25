import 'dart:async';

import 'package:get/get.dart';
import 'package:readr/controller/notify/notifyItemController.dart';
import 'package:readr/getxServices/hiveService.dart';
import 'package:readr/getxServices/userService.dart';
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
  final List<Notify> _allNotifies = [];
  late final Timer _notifyTimer;

  @override
  void onInit() {
    fetchNotifies();
    fetchAnnouncements();
    //auto refetch every 10 minutes
    _notifyTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      fetchNotifies();
      fetchAnnouncements();
    });
    //delete notifies when user logged out
    ever<bool>(Get.find<UserService>().isMember, (callback) {
      if (callback) {
        fetchNotifies();
      } else {
        unReadNotifyList.clear();
        readNotifyList.clear();
        Get.find<HiveService>().deleteNotifyList();
      }
    });
    super.onInit();
  }

  @override
  void onClose() {
    _notifyTimer.cancel();
    super.onClose();
  }

  void readAll() {
    if (unReadNotifyList.isNotEmpty) {
      for (var notifyPageItem in unReadNotifyList) {
        Get.find<NotifyItemController>(tag: notifyPageItem.id)
            .alreadyRead
            .value = true;
      }
      readNotifyList.insertAll(0, unReadNotifyList);
      unReadNotifyList.clear();
      for (var notify in _allNotifies) {
        notify.isRead = true;
      }
      Get.find<HiveService>().updateNotifyList(_allNotifies);
    }
  }

  Future<void> fetchNotifies() async {
    List<Notify> localNotifies = Get.find<HiveService>().localNotifies;
    //remove notifies older than a week
    localNotifies.removeWhere((element) => element.actionTime
        .isBefore(DateTime.now().subtract(const Duration(days: 7))));
    List<Notify> newNotifies = await notifyRepos
        .fetchNotifies()
        .timeout(const Duration(seconds: 10), onTimeout: () => []);

    _allNotifies.assignAll(newNotifies);

    //update notifies that still exist
    for (var notify in localNotifies) {
      int index = _allNotifies.indexWhere((element) => element.id == notify.id);
      if (index != -1) {
        _allNotifies[index] = notify;
      }
    }

    //update notify local db with new list
    Get.find<HiveService>().updateNotifyList(_allNotifies);

    List<NotifyPageItem> allPageItems =
        _generatePageItemFromNotifies(_allNotifies);
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

  //combine notifies that type and objectId is same
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
    pageItemList.sort((a, b) => b.actionTime.compareTo(a.actionTime));

    return pageItemList;
  }

  void readItem(String id) {
    int itemIndex = unReadNotifyList.indexWhere((element) => element.id == id);
    if (itemIndex != -1) {
      List<Notify> relatedNotifies =
          unReadNotifyList[itemIndex].relatedNotifies;
      for (var notify in relatedNotifies) {
        _allNotifies
            .firstWhereOrNull((element) => element.id == notify.id)
            ?.isRead = true;
      }
      Get.find<HiveService>().updateNotifyList(_allNotifies);
      readNotifyList.add(unReadNotifyList[itemIndex]);
      readNotifyList.sort((a, b) => b.actionTime.compareTo(a.actionTime));
      unReadNotifyList.removeAt(itemIndex);
    }
  }

  Future<void> fetchAnnouncements() async {
    announcementList.assignAll(await notifyRepos.fetchAnnouncements());
  }
}
