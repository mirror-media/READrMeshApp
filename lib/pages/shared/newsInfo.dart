import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/timestamp.dart';

class NewsInfo extends StatelessWidget {
  final NewsListItem newsListItem;
  const NewsInfo(this.newsListItem);

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<PickableItemController>(tag: newsListItem.controllerTag);
    return Obx(
      () {
        List<Widget> children = [];
        int displayCommentCount = controller.commentCount.value;

        if (displayCommentCount != 0) {
          children.add(Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ImageIcon(
                AssetImage(commentIconPng),
                size: 17,
                color: readrBlack50,
              ),
              const SizedBox(width: 3),
              Text(
                displayCommentCount.toString(),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  leading: 0.5,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: readrBlack50,
                ),
              ),
            ],
          ));
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: readrBlack20,
            ),
          ));
        }

        children.add(Timestamp(newsListItem.publishedDate));

        if (newsListItem.payWall) {
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: readrBlack20,
            ),
          ));
          children.add(const Text(
            '付費文章',
            strutStyle: StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style: TextStyle(
              fontSize: 12,
              color: readrBlack50,
            ),
          ));
        }

        if (newsListItem.fullScreenAd) {
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: readrBlack20,
            ),
          ));
          children.add(const Text(
            '蓋板廣告',
            strutStyle: StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style: TextStyle(
              fontSize: 12,
              color: readrBlack50,
            ),
          ));
        }

        return SizedBox(
          height: 17,
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        );
      },
    );
  }
}
