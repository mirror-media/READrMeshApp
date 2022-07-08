import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/announcement.dart';
import 'package:readr/pages/notify/notifyItem.dart';

class NotifyPage extends GetView<NotifyPageController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '通知',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: readrBlack,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              PlatformIcons(context).clear,
              color: readrBlack87,
              size: 26,
            ),
            tooltip: '關閉',
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: _buildBody(context),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildBody(BuildContext context) {
    return ListView(
      children: [
        _announcementBlock(),
        _buildUnreadNotifies(),
        _buildReadNotifies(),
        Obx(
          () {
            if (controller.unReadNotifyList.isEmpty &&
                controller.readNotifyList.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 16, 12),
                    child: Text(
                      '新通知',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: readrBlack87,
                        fontFamily: 'PingFang TC',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      '目前沒有新通知...',
                      style: TextStyle(
                        color: readrBlack66,
                        fontSize: 14,
                      ),
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
            _announcementItem(controller.announcementList[index]),
        separatorBuilder: (context, index) => const Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 20,
          endIndent: 20,
          color: Colors.black12,
        ),
        itemCount: controller.announcementList.length,
      ),
    );
  }

  Widget _announcementItem(Announcement announcement) {
    String title;
    Color backgroundColor;
    switch (announcement.type) {
      case AnnouncementType.maintain:
        title = '系統維修公告';
        backgroundColor = const Color.fromRGBO(255, 245, 245, 1);
        break;
      case AnnouncementType.newFeature:
        title = '新功能上線囉～';
        backgroundColor = const Color.fromRGBO(242, 253, 255, 1);
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
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: readrBlack87,
              fontFamily: 'PingFang TC',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            announcement.content,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: readrBlack66,
              fontFamily: 'PingFang TC',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadNotifies() {
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
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '新通知',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                        color: readrBlack87,
                        fontFamily: 'PingFang TC',
                      ),
                    ),
                    TextButton(
                      onPressed: () => controller.readAll(),
                      child: const Text(
                        '全部標為已讀',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Colors.blue,
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
              height: 0.5,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
              color: Colors.black12,
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
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: const Text(
                  '之前的通知',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: readrBlack87,
                    fontFamily: 'PingFang TC',
                  ),
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
              height: 0.5,
              thickness: 0.5,
              indent: 20,
              endIndent: 20,
              color: Colors.black12,
            );
          },
          itemCount: controller.readNotifyList.length + 1,
        );
      },
    );
  }
}
