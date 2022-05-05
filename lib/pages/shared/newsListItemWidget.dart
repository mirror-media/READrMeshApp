import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:readr/pages/story/newsStoryPage.dart';
import 'package:shimmer/shimmer.dart';

class NewsListItemWidget extends StatelessWidget {
  final NewsListItem news;
  final bool hidePublisher;
  const NewsListItemWidget(
    this.news, {
    this.hidePublisher = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => NewsStoryPage(
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
              child: Text(
                news.source.title,
                style: const TextStyle(color: readrBlack50, fontSize: 12),
              ),
            ),
          if (news.heroImageUrl == null)
            Text(
              news.title,
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
                    child: Text(
                      news.title,
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
              errorWidget: (context, url, error) => Text(
                news.title,
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
                      child: Text(
                        news.title,
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
            NewsListItemPick(news),
          ),
        ],
      ),
    );
  }
}
