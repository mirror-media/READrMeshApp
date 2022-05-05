import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheet.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/story/newsStoryPage.dart';
import 'package:shimmer/shimmer.dart';

class LatestCommentItem extends StatefulWidget {
  final NewsListItem news;
  const LatestCommentItem(this.news);

  @override
  _LatestCommentItemState createState() => _LatestCommentItemState();
}

class _LatestCommentItemState extends State<LatestCommentItem> {
  late MemberFollowableItem memberFollowableItem;

  @override
  void initState() {
    super.initState();
    memberFollowableItem = MemberFollowableItem(
      widget.news.showComment!.member,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Get.to(
                () => NewsStoryPage(
                  news: widget.news,
                ),
                fullscreenDialog: true,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.news.heroImageUrl != null)
                  CachedNetworkImage(
                    imageUrl: widget.news.heroImageUrl!,
                    placeholder: (context, url) => SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width / 2,
                      child: Shimmer.fromColors(
                        baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                        highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width / 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(),
                    imageBuilder: (context, imageProvider) {
                      return Image(
                        image: imageProvider,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width / 2,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Text(
                    widget.news.source.title,
                    style: const TextStyle(color: readrBlack50, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 12, right: 12, bottom: 8),
                  child: Text(
                    widget.news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: readrBlack87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 16),
                  child: NewsInfo(widget.news),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 12,
            endIndent: 12,
            color: readrBlack10,
            height: 1,
            thickness: 1,
          ),
          GestureDetector(
            onTap: () async {
              await CommentBottomSheet.showCommentBottomSheet(
                context: context,
                clickComment: widget.news.showComment!,
                item: NewsListItemPick(widget.news),
              );
            },
            child: _commentsWidget(context, widget.news.showComment!),
          ),
        ],
      ),
    );
  }

  Widget _commentsWidget(BuildContext context, Comment comment) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 16, right: 12, left: 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => PersonalFilePage(viewMember: comment.member));
            },
            child: Row(
              children: [
                ProfilePhotoWidget(
                  comment.member,
                  22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExtendedText(
                        comment.member.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        joinZeroWidthSpace: true,
                        style: const TextStyle(
                          color: readrBlack87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '@${comment.member.customId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: readrBlack50,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                FollowButton(
                  memberFollowableItem,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8.5),
            child: ExtendedText(
              comment.content,
              maxLines: 2,
              style: const TextStyle(
                color: Color.fromRGBO(0, 9, 40, 0.66),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              joinZeroWidthSpace: true,
              overflowWidget: TextOverflowWidget(
                position: TextOverflowPosition.end,
                child: RichText(
                  text: const TextSpan(
                    text: '... ',
                    style: TextStyle(
                      color: Color.fromRGBO(0, 9, 40, 0.66),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      TextSpan(
                        text: '看完整留言',
                        style: TextStyle(
                          color: readrBlack50,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
