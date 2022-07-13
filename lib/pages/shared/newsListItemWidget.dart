import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:shimmer/shimmer.dart';

class NewsListItemWidget extends StatelessWidget {
  final NewsListItem news;
  final bool hidePublisher;
  final bool isInMyPersonalFile;
  final bool showPickTooltip;
  const NewsListItemWidget(
    this.news, {
    this.hidePublisher = false,
    this.isInMyPersonalFile = false,
    this.showPickTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => StoryPage(
          news: news,
        ),
        fullscreenDialog: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hidePublisher)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (news.source != null)
                    GestureDetector(
                      onTap: () => Get.to(() => PublisherPage(
                            news.source!,
                          )),
                      child: ExtendedText(
                        news.source!.title,
                        joinZeroWidthSpace: true,
                        style:
                            const TextStyle(color: readrBlack50, fontSize: 12),
                      ),
                    ),
                  IconButton(
                    padding: const EdgeInsets.all(9),
                    alignment: Alignment.centerRight,
                    onPressed: () async =>
                        await MoreActionBottomSheet.showMoreActionSheet(
                      context: context,
                      objective: PickObjective.story,
                      id: news.id,
                      controllerTag: news.controllerTag,
                      url: news.url,
                    ),
                    icon: const Icon(
                      CupertinoIcons.ellipsis,
                      color: readrBlack66,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          if (news.heroImageUrl == null)
            ExtendedText(
              news.title,
              joinZeroWidthSpace: true,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: readrBlack87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (news.heroImageUrl != null)
            CachedNetworkImage(
              imageUrl: news.heroImageUrl!,
              placeholder: (context, url) => Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ExtendedText(
                      news.title,
                      joinZeroWidthSpace: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    width: 96,
                    height: 96 / 2,
                    child: Shimmer.fromColors(
                      baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                      highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          width: 96,
                          height: 96 / 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              errorWidget: (context, url, error) => ExtendedText(
                news.title,
                joinZeroWidthSpace: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: readrBlack87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              imageBuilder: (context, imageProvider) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: ExtendedText(
                        news.title,
                        joinZeroWidthSpace: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: readrBlack87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 12),
                      width: 96,
                      height: 96 / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image(
                          image: imageProvider,
                          width: 96,
                          height: 96 / 2,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  ],
                );
              },
              fit: BoxFit.cover,
            ),
          const SizedBox(height: 8),
          NewsInfo(news),
          const SizedBox(height: 16),
          PickBar(
            'News${news.id}',
            isInMyPersonalFile: isInMyPersonalFile,
            showPickTooltip: showPickTooltip,
          ),
        ],
      ),
    );
  }
}
