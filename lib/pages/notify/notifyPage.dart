import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/announcement.dart';
import 'package:readr/pages/notify/notifyItem.dart';

class NotifyPage extends GetView<NotifyPageController> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.readAll();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'notifications'.tr,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w400),
          ),
          actions: [
            IconButton(
              icon: Icon(
                PlatformIcons(context).clear,
                color: Theme.of(context).appBarTheme.foregroundColor,
                size: 26,
              ),
              tooltip: 'close'.tr,
              onPressed: () {
                controller.readAll();
                Get.back();
              },
            ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: [
        _announcementBlock(),
        _buildUnreadNotifies(context),
        _buildReadNotifies(),
        Obx(
          () {
            if (controller.unReadNotifyList.isEmpty &&
                controller.readNotifyList.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                    child: Text(
                      'newNotifications'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'noNewNotification'.tr,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _announcementBlock() {
    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemBuilder: (context, index) =>
            _announcementItem(context, controller.announcementList[index]),
        separatorBuilder: (context, index) => const Divider(
          indent: 20,
          endIndent: 20,
        ),
        itemCount: controller.announcementList.length,
      ),
    );
  }

  Widget _announcementItem(BuildContext context, Announcement announcement) {
    String title;
    Color backgroundColor;
    switch (announcement.type) {
      case AnnouncementType.maintain:
        title = 'maintainAnnouncement'.tr;
        backgroundColor =
            Theme.of(context).extension<CustomColors>()!.highlightRed!;
        break;
      case AnnouncementType.newFeature:
        title = 'newFeatureAnnouncement'.tr;
        backgroundColor =
            Theme.of(context).extension<CustomColors>()!.highlightBlue!;
        break;
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            announcement.content,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadNotifies(BuildContext context) {
    return Obx(
      () {
        if (controller.unReadNotifyList.isEmpty) {
          return Container();
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                color: Theme.of(context).backgroundColor,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'newNotifications'.tr,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    TextButton(
                      onPressed: () => controller.readAll(),
                      child: Text(
                        'markAllAsRead'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color:
                              Theme.of(context).extension<CustomColors>()?.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return NotifyItem(
              controller.unReadNotifyList[index - 1],
              isRead: false,
              key: Key(controller.unReadNotifyList[index - 1].id),
            );
          },
          separatorBuilder: (context, index) {
            if (index == 0) {
              return Container();
            }

            return const Divider(
              indent: 20,
              endIndent: 20,
            );
          },
          itemCount: controller.unReadNotifyList.length + 1,
        );
      },
    );
  }

  Widget _buildReadNotifies() {
    return Obx(
      () {
        if (controller.readNotifyList.isEmpty) {
          return Container();
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                color: Theme.of(context).backgroundColor,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Text(
                  'previousNotifications'.tr,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              );
            }

            return NotifyItem(
              controller.readNotifyList[index - 1],
              key: Key(controller.readNotifyList[index - 1].id),
            );
          },
          separatorBuilder: (context, index) {
            if (index == 0) {
              return Container();
            }

            return const Divider(
              indent: 20,
              endIndent: 20,
            );
          },
          itemCount: controller.readNotifyList.length + 1,
        );
      },
    );
  }
}
