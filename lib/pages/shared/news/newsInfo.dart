import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/timestamp.dart';

class NewsInfo extends StatelessWidget {
  final NewsListItem newsListItem;
  const NewsInfo(this.newsListItem, {Key? key}) : super(key: key);

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
              Icon(
                CupertinoIcons.bubble_left,
                size: 11,
                color: Theme.of(context).primaryColorLight,
              ),
              const SizedBox(width: 3),
              Text(
                displayCommentCount.toString(),
                strutStyle: const StrutStyle(
                  forceStrutHeight: true,
                  leading: 0.5,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 12),
              ),
            ],
          ));
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).dividerColor,
            ),
          ));
        }

        children.add(Timestamp(
          newsListItem.publishedDate,
          key: Key(newsListItem.controllerTag),
        ));

        if (newsListItem.payWall) {
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).dividerColor,
            ),
          ));
          children.add(Text(
            'paidArticle'.tr,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
          ));
        }

        if (newsListItem.fullScreenAd) {
          children.add(Container(
            width: 2,
            height: 2,
            margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).dividerColor,
            ),
          ));
          children.add(Text(
            'fullScreenAd'.tr,
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              leading: 0.5,
            ),
            style:
                Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
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
