import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:shimmer/shimmer.dart';

class CollectionStoryItem extends StatelessWidget {
  final NewsListItem story;
  final bool inTimeline;
  final bool inCustomTime;
  const CollectionStoryItem(
    this.story, {
    this.inTimeline = false,
    this.inCustomTime = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (story.heroImageUrl == null || inCustomTime)
          Text(
            story.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).extension<CustomColors>()?.primary700,
              fontSize: 16,
              fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        if (story.heroImageUrl != null && !inCustomTime)
          CachedNetworkImage(
            imageUrl: story.heroImageUrl!,
            placeholder: (context, url) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary700,
                      fontSize: 16,
                      fontWeight:
                          GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Shimmer.fromColors(
                    baseColor: Theme.of(context)
                        .extension<CustomColors>()!
                        .shimmerBaseColor!,
                    highlightColor: Theme.of(context)
                        .extension<CustomColors>()!
                        .primaryLv6!,
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
            errorWidget: (context, url, error) => Text(
              story.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).extension<CustomColors>()?.primary700,
                fontSize: 16,
                fontWeight:
                    GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
              ),
            ),
            imageBuilder: (context, imageProvider) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context)
                            .extension<CustomColors>()
                            ?.primary700,
                        fontSize: 16,
                        fontWeight: GetPlatform.isIOS
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
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
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (story.source != null) ...[
                Text(
                  story.source!.title,
                  style: TextStyle(
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primary500,
                      fontSize: 12),
                ),
                if (!inCustomTime)
                  Container(
                    width: 2,
                    height: 2,
                    margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .extension<CustomColors>()
                          ?.primaryLv5,
                    ),
                  ),
              ],
              if (!inCustomTime)
                Timestamp(
                  story.publishedDate,
                  key: Key(story.controllerTag),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
