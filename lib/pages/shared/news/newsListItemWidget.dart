import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/publisher/publisherPage.dart';
import 'package:readr/pages/shared/moreActionBottomSheet.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/storyPage.dart';
import 'package:shimmer/shimmer.dart';

class NewsListItemWidget extends StatelessWidget {
  final NewsListItem news;
  final bool hidePublisher;
  final bool isInMyPersonalFile;
  final bool showPickTooltip;
  final bool inTimeline;
  final bool pushReplacement;
  const NewsListItemWidget(
    this.news, {
    this.hidePublisher = false,
    this.isInMyPersonalFile = false,
    this.showPickTooltip = false,
    this.inTimeline = false,
    this.pushReplacement = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (pushReplacement) {
          Get.off(
            () => StoryPage(
              news: news,
            ),
            fullscreenDialog: true,
            preventDuplicates: false,
          );
        } else {
          Get.to(
            () => StoryPage(
              news: news,
            ),
            fullscreenDialog: true,
          );
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hidePublisher)
            Container(
              padding: const EdgeInsets.only(bottom: 4),
              height: 24,
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
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    padding: const EdgeInsets.only(right: 4, left: 10),
                    alignment: Alignment.centerRight,
                    onPressed: () async => await showMoreActionSheet(
                      context: context,
                      objective: PickObjective.story,
                      id: news.id,
                      controllerTag: news.controllerTag,
                      url: news.url,
                      newsListItem: news,
                    ),
                    icon: Icon(
                      CupertinoIcons.ellipsis,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary600,
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16),
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
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 16),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 12),
                    width: inTimeline ? 48 : 96,
                    height: 48,
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary200!
                          .withOpacity(0.15),
                      highlightColor: Theme.of(context)
                          .extension<CustomColors>()!
                          .primary200!,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Container(
                          width: inTimeline ? 48 : 96,
                          height: 48,
                          color: Theme.of(context).backgroundColor,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 16),
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
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image(
                          image: imageProvider,
                          width: inTimeline ? 48 : 96,
                          height: 48,
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
          NewsInfo(news, key: Key(news.id)),
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
