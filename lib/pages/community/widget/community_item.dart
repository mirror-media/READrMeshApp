import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/models/communityListItem.dart';
import 'package:readr/pages/community/comment/commentBottomSheet.dart';
import 'package:readr/pages/community/widget/comments_widget.dart';
import 'package:readr/pages/community/widget/item_bar.dart';
import 'package:readr/pages/shared/collection/collectionInfo.dart';
import 'package:readr/pages/shared/collection/collectionTag.dart';
import 'package:readr/pages/shared/news/newsInfo.dart';
import 'package:readr/pages/shared/pick/pickBar.dart';
import 'package:shimmer/shimmer.dart';
import 'package:readr/models/communityListItemType.dart';

class CommunityItem extends StatelessWidget {
  final CommunityListItem item;
  final Function(CommunityListItem) onMoreAction;
  final Function? onCommentTap;
  final Function(CommunityListItem)? onTapItem;
  final Function(CommunityListItem)? onTapAuthor;
  final String? firstItemId;

  const CommunityItem({
    super.key,
    required this.item,
    required this.onMoreAction,
    this.onCommentTap,
    this.onTapItem,
    this.onTapAuthor,
    this.firstItemId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ItemBar(
            item: item,
            firstTwoMembers: item.firstTwoMembers,
            onMoreAction: onMoreAction,
          ),
          InkWell(
            onTap: onTapItem != null ? () => onTapItem!(item) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    if (item.heroImageUrl != null)
                      CachedNetworkImage(
                        imageUrl: item.heroImageUrl!,
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
                      ),
                    if (item.shouldShowCollectionTag)
                      const Padding(
                        padding: EdgeInsets.only(top: 8, right: 8),
                        child: CollectionTag(),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: GestureDetector(
                    onTap:
                        onTapAuthor != null ? () => onTapAuthor!(item) : null,
                    child: item.displayAuthorText != null
                        ? ExtendedText(
                            item.displayAuthorText!,
                            joinZeroWidthSpace: true,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                if (item.displayTitleText != null)
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 4, left: 20, right: 20, bottom: 8),
                    child: ExtendedText(
                      item.displayTitleText!,
                      joinZeroWidthSpace: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
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
                  firstItemId != null && item.itemId == firstItemId,
            ),
          ),
          if (item.showComment != null) ...[
            const Divider(
              indent: 20,
              endIndent: 20,
            ),
            InkWell(
              onTap: () async {
                if (onCommentTap != null) {
                  onCommentTap!();
                } else {
                  await CommentBottomSheet.showCommentBottomSheet(
                    context: context,
                    clickComment: item.showComment!,
                    objective: item.commentObjective,
                    id: item.itemId,
                    controllerTag: item.controllerTag,
                  );
                }
              },
              child: CommentsWidget(comment: item.showComment!),
            ),
          ],
        ],
      ),
    );
  }
}
