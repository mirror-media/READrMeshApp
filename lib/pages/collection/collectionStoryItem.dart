import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:shimmer/shimmer.dart';

class CollectionStoryItem extends StatelessWidget {
  final CollectionStory story;
  const CollectionStoryItem(this.story, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (story.news!.heroImageUrl == null)
          Text(
            story.news!.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: readrBlack87,
              fontSize: 16,
              fontWeight: GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
            ),
          ),
        if (story.news!.heroImageUrl != null)
          CachedNetworkImage(
            imageUrl: story.news!.heroImageUrl!,
            placeholder: (context, url) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    story.news!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: readrBlack87,
                      fontSize: 16,
                      fontWeight:
                          GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
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
            errorWidget: (context, url, error) => Text(
              story.news!.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: readrBlack87,
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
                      story.news!.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: readrBlack87,
                        fontSize: 16,
                        fontWeight: GetPlatform.isIOS
                            ? FontWeight.w500
                            : FontWeight.w600,
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
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (story.news!.source != null) ...[
                Text(
                  story.news!.source!.title,
                  style: const TextStyle(color: readrBlack50, fontSize: 12),
                ),
                Container(
                  width: 2,
                  height: 2,
                  margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: readrBlack20,
                  ),
                ),
              ],
              Timestamp(
                story.news!.publishedDate,
                key: Key(story.news!.controllerTag),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
