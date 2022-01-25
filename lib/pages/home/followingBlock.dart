import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheet.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';

class FollowingBlock extends StatelessWidget {
  final List<NewsListItem> followingStories;
  final Member member;
  const FollowingBlock(this.followingStories, this.member);

  @override
  Widget build(BuildContext context) {
    if (followingStories.isEmpty) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            '快去追蹤些人吧!',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: homeScreenBackgroundColor,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemBuilder: (context, index) =>
              _followingItem(context, followingStories[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 8.5),
          itemCount: followingStories.length,
        ),
      ),
    );
  }

  Widget _followingItem(BuildContext context, NewsListItem item) {
    return InkWell(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pickBar(item.followingPickMembers),
            CachedNetworkImage(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              imageUrl: item.heroImageUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey,
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey,
                child: const Icon(Icons.error),
              ),
              fit: BoxFit.cover,
            ),
            if (item.source != null)
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                child: Text(
                  item.source!.title,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.only(top: 4, left: 20, right: 20, bottom: 8),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: NewsInfo(item),
            ),
            if (item.showComment != null) ...[
              const Divider(
                indent: 20,
                endIndent: 20,
                color: Colors.black12,
                height: 1,
                thickness: 1,
              ),
              InkWell(
                onTap: () async {
                  await CommentBottomSheet.showCommentBottomSheet(
                    context: context,
                    member: member,
                    clickComment: item.showComment!,
                    storyId: item.id,
                  );
                },
                child: _commentsWidget(item.showComment!),
              ),
            ]
          ],
        ),
      ),
      onTap: () {},
    );
  }

  Widget _pickBar(List<Member> members) {
    if (members.isEmpty) {
      return Container();
    }
    List<Member> firstTwoMember = [];
    for (int i = 0; i < members.length && i < 2; i++) {
      firstTwoMember.add(members[i]);
    }

    List<Widget> children = [
      ProfilePhotoStack(firstTwoMember, 14),
      const SizedBox(width: 8),
    ];
    if (firstTwoMember.length == 1) {
      children.add(Flexible(
        child: Text(
          firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '精選了這篇',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    } else {
      children.add(Flexible(
        child: Text(
          firstTwoMember[0].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '及',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
      ));
      children.add(Flexible(
        child: Text(
          firstTwoMember[1].nickname,
          style: const TextStyle(fontSize: 14, color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ));
      children.add(const Text(
        '都精選了這篇',
        style: TextStyle(fontSize: 14, color: Colors.black54),
        maxLines: 1,
      ));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _commentsWidget(Comment comment) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        comment.member.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black26,
                      ),
                    ),
                    Timestamp(comment.publishDate),
                  ],
                ),
                const SizedBox(height: 8.5),
                ExtendedText(
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
                              color: Colors.black54,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
