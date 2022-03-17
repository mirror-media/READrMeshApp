import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/timestamp.dart';

class NewsInfo extends StatelessWidget {
  final NewsListItem newsListItem;
  final int? commentCount;
  const NewsInfo(this.newsListItem, {this.commentCount});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    int displayCommentCount = commentCount ?? newsListItem.commentCount;
    if (displayCommentCount != 0) {
      children.add(SizedBox(
        height: 22,
        child: Row(
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
              style: const TextStyle(
                fontSize: 12,
                color: readrBlack50,
                height: 1.4,
              ),
            ),
          ],
        ),
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
        style: TextStyle(
          fontSize: 13,
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
        style: TextStyle(
          fontSize: 13,
          color: readrBlack50,
        ),
      ));
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
