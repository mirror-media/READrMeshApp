import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/pages/community/comment/commentBottomSheet.dart';
import 'package:readr/pages/community/community_controller.dart';
import 'package:readr/pages/community/widget/comments_widget.dart';
import 'package:readr/pages/community/widget/item_bar.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:shimmer/shimmer.dart';

class CommunityItem extends StatelessWidget {
  final CommunityListItem item;
  final CommunityController controller;

  const CommunityItem({
    Key? key,
    required this.item,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemBar(
            item: item,
            controller: controller,
          ),
          InkWell(
            onTap: item.tapItem,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Obx(
                      () {
                        final heroImageUrl = item.heroImageUrl.value;
                        return CachedNetworkImage(
                          imageUrl: heroImageUrl ?? '',
                          placeholder: (context, url) => SizedBox(
                            width: Get.width,
                            height: Get.width / 2,
                            child: Shimmer.fromColors(
                              baseColor: Theme.of(context).dividerColor,
                              highlightColor: Theme.of(context).shadowColor,
                              child: Container(
                                width: Get.width,
                                height: Get.width / 2,
                                color: Theme.of(context).backgroundColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(),
                          imageBuilder: (context, imageProvider) {
                            return Image(
                              image: imageProvider,
                              width: Get.width,
                              height: Get.width / 2,
                              fit: BoxFit.cover,
                            );
                          },
                        );
                      },
                    ),
                    if (controller.shouldShowCollectionTag(item))
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: CollectionTag(),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: GestureDetector(
                    onTap: item.tapAuthor,
                    child: Obx(
                      () {
                        return ExtendedText(
                          controller.getAuthorText(item),
                          joinZeroWidthSpace: true,
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 20, right: 20, bottom: 8),
                  child: Obx(
                    () {
                      return ExtendedText(
                        controller.getItemTitle(item),
                        joinZeroWidthSpace: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium,
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: (item.type == CommunityListItemType.commentStory ||
                          item.type == CommunityListItemType.pickStory)
                      ? NewsInfo(
                          item.newsListItem!,
                          key: Key(item.newsListItem!.id),
                        )
                      : CollectionInfo(
                          item.collection!,
                          key: Key(item.collection!.id),
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: PickBar(
              item.controllerTag,
              showPickTooltip:
                  item.itemId == controller.communityList.first.itemId,
            ),
          ),
          if (item.showComment != null) ...[
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            InkWell(
              onTap: () async {
                final objective = controller.getCommentObjective(item);
                await CommentBottomSheet.showCommentBottomSheet(
                  context: context,
                  clickComment: item.showComment!,
                  objective: objective,
                  id: item.itemId,
                  controllerTag: item.controllerTag,
                );
              },
              child: CommentsWidget(comment: item.showComment!),
            ),
          ],
        ],
      ),
    );
  }
}
