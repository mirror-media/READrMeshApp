import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/notify/notifyItemController.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/notifyPageItem.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/pages/story/storyPage.dart';

class NotifyItem extends GetView<NotifyItemController> {
  final bool isRead;
  final NotifyPageItem notify;
  const NotifyItem(this.notify, {this.isRead = true, Key? key})
      : super(key: key);

  @override
  String get tag => notify.id;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotifyItemController>(tag: notify.id)) {
      Get.put<NotifyItemController>(NotifyItemController(isRead: isRead),
          tag: notify.id);
    }

    return InkWell(
      onTap: () {
        if (notify.newsListItem != null) {
          Get.to(
            () => StoryPage(
              news: notify.newsListItem!,
            ),
            fullscreenDialog: true,
          );
        } else if (notify.collection != null) {
          Get.to(() => CollectionPage(
                notify.collection!,
              ));
        } else {
          Get.to(() => PersonalFilePage(
                viewMember: notify.senderList.first,
              ));
        }
        controller.alreadyRead.value = true;
        Get.find<NotifyPageController>().readItem(notify.id);
      },
      child: Obx(
        () => Container(
          color: controller.alreadyRead.value
              ? Colors.white
              : const Color.fromRGBO(242, 253, 255, 1),
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePhotoWidget(
                notify.senderList.first,
                22,
                textSize: 22,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextWidget(),
                    const SizedBox(
                      height: 4,
                    ),
                    Timestamp(
                      notify.actionTime,
                      key: Key(notify.id),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextWidget() {
    String mainText;
    if (notify.senderList.length == 1) {
      mainText = notify.senderList.first.nickname;
    } else if (notify.senderList.length == 2) {
      mainText =
          '${notify.senderList.first.nickname}及${notify.senderList[1].nickname}';
    } else {
      mainText =
          '${notify.senderList.first.nickname}、${notify.senderList[1].nickname}及其他${notify.senderList.length - 2}人';
    }

    List<InlineSpan> textChildren = [];
    switch (notify.type) {
      case NotifyType.comment:
        textChildren.add(const TextSpan(
          text: '也在',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: readrBlack66,
          ),
        ));
        textChildren.add(TextSpan(
          text: notify.newsListItem!.source?.title,
          style: TextStyle(
            fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
            color: readrBlack,
          ),
        ));
        textChildren.add(const TextSpan(
          text: '的新聞下留言。',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: readrBlack66,
          ),
        ));
        break;

      case NotifyType.follow:
        String text = '開始追蹤你。';
        textChildren = [
          TextSpan(
            text: notify.senderList.length > 1 ? '都$text' : text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ];
        break;

      case NotifyType.like:
        String text = '喜歡你的留言「${notify.comment?.content}」。';
        textChildren = [
          TextSpan(
            text: notify.senderList.length > 1 ? '都$text' : text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ];
        break;

      case NotifyType.pickCollection:
        String text = '精選了你的集錦「${notify.collection?.title}」。';
        textChildren = [
          TextSpan(
            text: notify.senderList.length > 1 ? '都$text' : text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ];
        break;

      case NotifyType.commentCollection:
        String text = '在你的集錦下留言。';
        textChildren = [
          TextSpan(
            text: notify.senderList.length > 1 ? '都$text' : text,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ];
        break;

      case NotifyType.createCollection:
        textChildren = [
          TextSpan(
            text: '建立了新的集錦「${notify.collection?.title}」。',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: readrBlack66,
            ),
          ),
        ];
        break;
    }

    return ExtendedText.rich(
      TextSpan(
        text: mainText,
        style: TextStyle(
          fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
          color: readrBlack,
        ),
        children: textChildren,
      ),
      joinZeroWidthSpace: true,
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      style: const TextStyle(
        color: readrBlack66,
        fontSize: 14,
        fontFamily: 'PingFang TC',
      ),
    );
  }
}
